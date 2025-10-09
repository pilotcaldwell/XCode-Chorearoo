import SwiftUI
import CoreData

struct ParentApprovalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all pending chore completions
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
        predicate: NSPredicate(format: "status == %@", "pending"),
        animation: .default)
    private var pendingCompletions: FetchedResults<ChoreCompletion>
    
    var body: some View {
        NavigationView {
            Group {
                if pendingCompletions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No pending approvals")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("All chores have been reviewed!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(pendingCompletions) { completion in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    // Child info
                                    Circle()
                                        .fill(Color(hex: completion.child?.avatarColor ?? "#3b82f6"))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(String(completion.child?.name?.prefix(1) ?? "?"))
                                                .foregroundColor(.white)
                                                .font(.headline)
                                        )
                                    
                                    VStack(alignment: .leading) {
                                        Text(completion.child?.name ?? "Unknown")
                                            .font(.headline)
                                        Text(completion.chore?.name ?? "Unknown Chore")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(completion.chore?.amount ?? 0, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                
                                // Completion date
                                if let completedAt = completion.completedAt {
                                    Text("Completed: \(completedAt, formatter: dateFormatter)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                // Action buttons
                                HStack(spacing: 12) {
                                    Button(action: {
                                        rejectCompletion(completion)
                                    }) {
                                        Text("Reject")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.1))
                                            .foregroundColor(.red)
                                            .cornerRadius(8)
                                    }
                                    
                                    Button(action: {
                                        approveCompletion(completion)
                                    }) {
                                        Text("Approve")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Approvals")
        }
    }
    
    private func approveCompletion(_ completion: ChoreCompletion) {
        // Update completion status
        completion.status = "approved"
        completion.approvedAt = Date()
        
        // Add money to child's balances
        if let child = completion.child {
            child.spendingBalance += completion.spendingAmount
            child.savingsBalance += completion.savingsAmount
            child.givingBalance += completion.givingAmount
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error approving completion: \(error)")
        }
    }
    
    private func rejectCompletion(_ completion: ChoreCompletion) {
        // Update completion status
        completion.status = "rejected"
        
        do {
            try viewContext.save()
        } catch {
            print("Error rejecting completion: \(error)")
        }
    }
}

// Date formatter for displaying dates nicely
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ParentApprovalsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
