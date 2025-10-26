import SwiftUI
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
        ZStack {
            KidTheme.mainGradient // Background for the whole screen - playful gradient
            
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
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(
                            KidTheme.cardGradient
                        ) // Card background with playful glassy gradient
                        .cornerRadius(12)
                        .opacity(chore.isActive ? 1.0 : 0.5)
                        .listRowBackground(Color.clear) // Clear default list row background to show gradient
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
                                .font(.system(size: 22, weight: .bold))
                                .padding(10)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } // Playful add button with color and rounded corners
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .font(.system(size: 18, weight: .semibold))
                            .padding(8)
                            .background(Color.accentColor.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .sheet(isPresented: $showingAddChore) {
                    AddChoreView()
                }
                .listStyle(.plain)
                .background(Color.clear) // Make list background clear to show ZStack background
            }
        }
        .edgesIgnoringSafeArea(.all) // Make gradient fill entire screen
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
