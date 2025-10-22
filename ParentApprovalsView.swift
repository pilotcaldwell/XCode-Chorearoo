import SwiftUI
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
        ZStack {
            KidTheme.mainGradient // Background gradient for the entire screen - fun and vibrant
            
            NavigationView {
                Group {
                    if pendingCompletions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill") // Added fill for playful accent
                                .font(.system(size: 60))
                                .foregroundStyle(KidTheme.green, .white) // Fun green and white gradient fill
                            Text("No pending approvals")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("All chores have been reviewed!")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
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
                                            HStack(spacing: 4) {
                                                Text(completion.child?.name ?? "Unknown")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                Image(systemName: "star.fill") // Playful accent icon
                                                    .foregroundColor(KidTheme.orange)
                                                    .font(.caption)
                                            }
                                            Text(completion.chore?.name ?? "Unknown Chore")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                        
                                        Text("$\(completion.chore?.amount ?? 0, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(KidTheme.green) // Use KidTheme green for money
                                    }
                                    
                                    // Completion date
                                    if let completedAt = completion.completedAt {
                                        Text("🗓 Completed: \(completedAt, formatter: dateFormatter)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    // Action buttons
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            rejectCompletion(completion)
                                        }) {
                                            HStack {
                                                Image(systemName: "xmark.circle.fill") // Icon for reject
                                                Text("Reject")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(KidTheme.orange) // KidTheme orange background for reject
                                            .foregroundColor(.white)
                                            .cornerRadius(12) // Rounded corners for lively feel
                                        }
                                        
                                        Button(action: {
                                            approveCompletion(completion)
                                        }) {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill") // Icon for approve
                                                Text("Approve")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(KidTheme.green) // KidTheme green background for approve
                                            .foregroundColor(.white)
                                            .cornerRadius(12) // Rounded corners for lively feel
                                        }
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    KidTheme.cardGradient
                                ) // Card-like glassy background for each approval row
                                .cornerRadius(16)
                                .listRowBackground(Color.clear) // Transparent background for list row to show gradient
                                .shadow(color: KidTheme.green.opacity(0.15), radius: 6, x: 0, y: 3) // Soft shadow for fun depth
                            }
                        }
                        .scrollContentBackground(.hidden) // Hide default list background to show gradient
                    }
                }
                .navigationTitle("Approvals")
                .foregroundColor(.white)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func approveCompletion(_ completion: ChoreCompletion) {
        // Safety check - only approve if status is pending
        guard completion.status == "pending" else {
            print("⚠️ Attempted to approve a chore that is not pending (status: \(completion.status ?? "nil"))")
            return
        }
        
        print("✅ Approving chore: \(completion.chore?.name ?? "unknown")")
        
        // Update completion status
        completion.status = "approved"
        completion.approvedAt = Date()
        
        // Add money to child's balances ONLY when approving
        if let child = completion.child {
            print("💰 Adding money to child: \(child.name ?? "unknown")")
            print("   Spending: $\(completion.spendingAmount)")
            print("   Savings: $\(completion.savingsAmount)")
            print("   Giving: $\(completion.givingAmount)")
            
            child.spendingBalance += completion.spendingAmount
            child.savingsBalance += completion.savingsAmount
            child.givingBalance += completion.givingAmount
            
            print("   New balances:")
            print("   Spending: $\(child.spendingBalance)")
            print("   Savings: $\(child.savingsBalance)")
            print("   Giving: $\(child.givingBalance)")
        }
        
        do {
            try viewContext.save()
            print("✅ Successfully approved and saved")
        } catch {
            print("❌ Error approving completion: \(error)")
        }
    }
    
    private func rejectCompletion(_ completion: ChoreCompletion) {
        // Safety check - only reject if status is pending
        guard completion.status == "pending" else {
            print("⚠️ Attempted to reject a chore that is not pending (status: \(completion.status ?? "nil"))")
            return
        }
        
        print("❌ Rejecting chore: \(completion.chore?.name ?? "unknown") for child: \(completion.child?.name ?? "unknown")")
        
        // Get child info for logging
        if let child = completion.child {
            print("   Child's current balances BEFORE rejection:")
            print("   Spending: $\(child.spendingBalance)")
            print("   Savings: $\(child.savingsBalance)")
            print("   Giving: $\(child.givingBalance)")
        }
        
        // Simply change status to rejected
        // ABSOLUTELY DO NOT add any money to child's account
        // ABSOLUTELY DO NOT modify child.spendingBalance
        // ABSOLUTELY DO NOT modify child.savingsBalance
        // ABSOLUTELY DO NOT modify child.givingBalance
        completion.status = "rejected"
        
        // Verify child balances haven't changed
        if let child = completion.child {
            print("   Child's balances AFTER rejection (should be same):")
            print("   Spending: $\(child.spendingBalance)")
            print("   Savings: $\(child.savingsBalance)")
            print("   Giving: $\(child.givingBalance)")
        }
        
        do {
            try viewContext.save()
            print("✅ Successfully rejected and saved - NO MONEY WAS ADDED")
        } catch {
            print("❌ Error rejecting completion: \(error)")
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
