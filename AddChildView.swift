import SwiftUI
import CoreData

struct AddChildView: View {
    // Access to Core Data
    @Environment(\.managedObjectContext) private var viewContext
    // Dismisses this screen when done
    @Environment(\.dismiss) private var dismiss
    
    // Form fields - these store what the user types
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var pin: String = ""
    @State private var avatarColor: Color = .blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Child Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("PIN (4 digits)", text: $pin)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Avatar Color")) {
                    ColorPicker("Choose Color", selection: $avatarColor)
                }
                
                Section {
                    Button("Save Child") {
                        saveChild()
                    }
                    .disabled(name.isEmpty || pin.isEmpty)
                }
            }
            .navigationTitle("Add Child")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    // This function saves the child to Core Data
    private func saveChild() {
        // Create a new Child object
        let newChild = Child(context: viewContext)
        newChild.id = UUID()
        newChild.name = name
        newChild.age = Int16(age) ?? 0
        newChild.pin = pin
        newChild.avatarColor = avatarColor.toHex()
        newChild.spendingBalance = 0.0
        newChild.savingsBalance = 0.0
        newChild.givingBalance = 0.0
        newChild.createdAt = Date()
        
        // Save to the database
        do {
            try viewContext.save()
            dismiss() // Close this screen
        } catch {
            print("Error saving child: \(error)")
        }
    }
}

// Helper to convert Color to hex string
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        return String(format:"#%06x", rgb)
    }
}

#Preview {
    AddChildView()
}
