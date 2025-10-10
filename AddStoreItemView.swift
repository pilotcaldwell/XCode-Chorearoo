import SwiftUI
import CoreData

struct AddStoreItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var itemDescription: String = ""
    @State private var price: String = ""
    @State private var selectedIcon: String = "gift.fill"
    
    let iconOptions = [
        "gift.fill", "gamecontroller.fill", "book.fill", "paintbrush.fill",
        "bicycle", "football.fill", "basketball.fill", "music.note",
        "headphones", "camera.fill", "tv.fill", "laptopcomputer",
        "iphone", "applewatch", "airpods", "tshirt.fill",
        "figure.walk", "car.fill", "airplane", "house.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name (e.g., Lego Set)", text: $name)
                    
                    TextField("Description (optional)", text: $itemDescription)
                    
                    HStack {
                        Text("$")
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Choose an Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                VStack {
                                    Image(systemName: icon)
                                        .font(.system(size: 30))
                                        .foregroundColor(selectedIcon == icon ? .white : .blue)
                                        .frame(width: 60, height: 60)
                                        .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button("Add to Store") {
                        saveStoreItem()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .navigationTitle("Add Store Item")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func saveStoreItem() {
        let newItem = StoreItem(context: viewContext)
        newItem.id = UUID()
        newItem.name = name
        newItem.itemDescription = itemDescription.isEmpty ? nil : itemDescription
        newItem.price = Double(price) ?? 0.0
        newItem.imageName = selectedIcon
        newItem.isAvailable = true
        newItem.createdAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving store item: \(error)")
        }
    }
}

#Preview {
    AddStoreItemView()
}
