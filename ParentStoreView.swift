import SwiftUI
import CoreData

struct ParentStoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreItem.name, ascending: true)],
        animation: .default)
    private var storeItems: FetchedResults<StoreItem>
    
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            Group {
                if storeItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No items in store")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add items that your kids can purchase with their earnings")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(storeItems) { item in
                            HStack(spacing: 15) {
                                // Icon
                                Image(systemName: item.imageName ?? "gift.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                
                                // Details
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "Unknown")
                                        .font(.headline)
                                    
                                    if let description = item.itemDescription, !description.isEmpty {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                    
                                    if !item.isAvailable {
                                        Text("Unavailable")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Spacer()
                                
                                // Price
                                Text("$\(item.price, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 8)
                            .opacity(item.isAvailable ? 1.0 : 0.5)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    toggleAvailability(item)
                                } label: {
                                    Label(item.isAvailable ? "Hide" : "Show",
                                          systemImage: item.isAvailable ? "eye.slash" : "eye")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Store")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddItem = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddStoreItemView()
            }
        }
    }
    
    private func toggleAvailability(_ item: StoreItem) {
        item.isAvailable.toggle()
        
        do {
            try viewContext.save()
        } catch {
            print("Error toggling availability: \(error)")
        }
    }
    
    private func deleteItem(_ item: StoreItem) {
        viewContext.delete(item)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}

#Preview {
    ParentStoreView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
