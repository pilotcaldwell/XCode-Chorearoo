import SwiftUI
import CoreData

struct CompleteChoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let child: Child
    
    // Fetch only active chores
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chore.name, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default)
    private var chores: FetchedResults<Chore>
    
    @State private var selectedChore: Chore?
    
    var body: some View {
        NavigationView {
            VStack {
                if chores.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No chores available")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Ask a parent to add chores to the library")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(chores) { chore in
                        Button(action: {
                            selectedChore = chore
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chore.name ?? "Unknown")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let description = chore.choreDescription, !description.isEmpty {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                                
                                Text("$\(chore.amount, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Complete Chore")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Complete Chore?", isPresented: Binding(
                get: { selectedChore != nil },
                set: { if !$0 { selectedChore = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    selectedChore = nil
                }
                Button("Complete") {
                    if let chore = selectedChore {
                        completeChore(chore)
                    }
                }
            } message: {
                if let chore = selectedChore {
                    Text("Mark \"\(chore.name ?? "")\" as complete for $\(chore.amount, specifier: "%.2f")?")
                }
            }
        }
    }
    
    private func completeChore(_ chore: Chore) {
        // Create a new chore completion
        let completion = ChoreCompletion(context: viewContext)
        completion.id = UUID()
        completion.status = "pending"
        completion.completedAt = Date()
        completion.weekStartDate = getStartOfWeek()
        
        // Calculate the fund splits (80/10/10)
        let total = chore.amount
        completion.spendingAmount = total * 0.8
        completion.savingsAmount = total * 0.1
        completion.givingAmount = total * 0.1
        
        // Link to child and chore
        completion.child = child
        completion.chore = chore
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error completing chore: \(error)")
        }
    }
    
    // Helper to get the start of the current week (Sunday)
    private func getStartOfWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components) ?? now
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let child = Child(context: context)
    child.name = "Sample Child"
    
    return CompleteChoreView(child: child)
        .environment(\.managedObjectContext, context)
}
