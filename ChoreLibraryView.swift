import SwiftUI
import CoreData

struct ChoreLibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all chores from Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chore.name, ascending: true)],
        animation: .default)
    private var chores: FetchedResults<Chore>
    
    @State private var showingAddChore = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chores) { chore in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chore.name ?? "Unknown")
                                .font(.headline)
                            
                            if let description = chore.choreDescription, !description.isEmpty {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            
                            // Show if active or inactive
                            if !chore.isActive {
                                Text("Inactive")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                        
                        // Amount
                        Text("$\(chore.amount, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                    .opacity(chore.isActive ? 1.0 : 0.5)
                }
                .onDelete(perform: deleteChores)
            }
            .navigationTitle("Chore Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddChore = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddChore) {
                AddChoreView()
            }
        }
    }
    
    private func deleteChores(offsets: IndexSet) {
        withAnimation {
            offsets.map { chores[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting chore: \(error)")
            }
        }
    }
}

#Preview {
    ChoreLibraryView()
}
