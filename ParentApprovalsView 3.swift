import SwiftUI
import CoreData

struct ParentApprovalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
        predicate: NSPredicate(format: "status == %@", "pending"),
        animation: .default)
    private var pendingApprovals: FetchedResults<ChoreCompletion>
    
    var body: some View {
        NavigationView {
            Group {
                if pendingApprovals.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("No pending approvals")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("All completed chores have been reviewed")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(pendingApprovals) { completion in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    // Child info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(completion.child?.name ?? "Unknown Child")
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text(completion.chore?.name ?? "Unknown Chore")
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Amount
                                    let totalAmount = completion.spendingAmount + completion.savingsAmount + completion.givingAmount
                                    Text("$\(totalAmount, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.green)
                                }
                                
                                // Date
                                if let date = completion.completedAt {
                                    Text("Completed: \(date, style: .date) at \(date, style: .time)")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                // Amount breakdown
                                HStack(spacing: 12) {
                                    Text("Spend: $\(completion.spendingAmount, specifier: "%.2f")")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("Save: $\(completion.savingsAmount, specifier: "%.2f")")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("Give: $\(completion.givingAmount, specifier: "%.2f")")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding(.top, 2)
                                
                                // Approval buttons
                                HStack(spacing: 16) {
                                    Button("Approve") {
                                        approveCompletion(completion)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    .tint(AppTheme.green)
                                    
                                    Button("Reject") {
                                        rejectCompletion(completion)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .tint(AppTheme.orange)
                                }
                                .padding(.top, 8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Approvals")
            .refreshable {
                // Refresh data if needed
            }
        }
    }
    
    private func approveCompletion(_ completion: ChoreCompletion) {
        completion.status = "approved"
        completion.approvedAt = Date()
        
        // Add the amounts to the child's balances
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
        completion.status = "rejected"
        
        do {
            try viewContext.save()
        } catch {
            print("Error rejecting completion: \(error)")
        }
    }
}

#Preview {
    ParentApprovalsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
