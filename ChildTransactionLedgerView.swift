import SwiftUI
import CoreData

struct ChildTransactionLedgerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let child: Child
    
    @FetchRequest private var allCompletions: FetchedResults<ChoreCompletion>
    @State private var showResetAlert = false
    
    init(child: Child) {
        self.child = child
        
        let childId = child.id?.uuidString ?? ""
        _allCompletions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
            predicate: NSPredicate(format: "child.id == %@", childId as CVarArg),
            animation: .default
        )
    }
    
    var totalBalance: Double {
        let spending = child.spendingBalance
        let savings = child.savingsBalance
        let giving = child.givingBalance
        return spending + savings + giving
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                balanceCard
                resetStatsButton
                transactionsSection
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.05))
        .navigationTitle(child.name ?? "Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset All Stats?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetStats()
            }
        } message: {
            Text("This will reset all balances and clear all transaction history. This action cannot be undone.")
        }
    }
    
    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(String(format: "$%.2f", totalBalance))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.purple)
            
            jarBalances
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private var jarBalances: some View {
        HStack(spacing: 16) {
            VStack {
                Text("Spending")
                    .font(.caption)
                    .foregroundColor(.purple)
                Text(String(format: "$%.2f", child.spendingBalance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
            
            VStack {
                Text("Savings")
                    .font(.caption)
                    .foregroundColor(.green)
                Text(String(format: "$%.2f", child.savingsBalance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            VStack {
                Text("Giving")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(String(format: "$%.2f", child.givingBalance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var resetStatsButton: some View {
        Button(action: {
            showResetAlert = true
        }) {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Reset Stats")
            }
            .foregroundColor(.red)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            transactionsSectionHeader
            
            if allCompletions.isEmpty {
                emptyTransactionsView
            } else {
                transactionsList
            }
        }
        .padding(.vertical)
    }
    
    private var transactionsSectionHeader: some View {
        HStack {
            Image(systemName: "book.fill")
                .foregroundColor(.purple)
            Text("Transactions")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text("No transactions yet")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var transactionsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(allCompletions.enumerated()), id: \.element.id) { index, completion in
                ParentTransactionRow(
                    completion: completion,
                    child: child,
                    runningBalance: calculateRunningBalance(upToIndex: index)
                )
                
                if completion.id != allCompletions.last?.id {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }
    
    // Calculate running balance at a specific transaction index
    private func calculateRunningBalance(upToIndex: Int) -> Double {
        // Start with current total balance
        var balance = totalBalance
        
        // Subtract all transactions that came AFTER this one (going backwards in time)
        // Since transactions are sorted newest first, we subtract transactions at indices 0 to upToIndex-1
        for i in 0..<upToIndex {
            let completion = Array(allCompletions)[i]
            if completion.status == "approved" {
                let amount = completion.spendingAmount + completion.savingsAmount + completion.givingAmount
                balance -= amount
            }
        }
        
        return balance
    }
    
    private func resetStats() {
        // Reset balances
        child.spendingBalance = 0
        child.savingsBalance = 0
        child.givingBalance = 0
        
        // Delete all completions for this child
        for completion in allCompletions {
            viewContext.delete(completion)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error resetting stats: \(error)")
        }
    }
}

struct ParentTransactionRow: View {
    let completion: ChoreCompletion
    let child: Child
    let runningBalance: Double
    
    var transactionAmount: Double {
        if completion.isBonus {
            return completion.spendingAmount + completion.savingsAmount + completion.givingAmount
        } else {
            return completion.chore?.amount ?? 0
        }
    }
    
    var isPending: Bool {
        completion.status == "pending"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(completion.isBonus ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: completion.isBonus ? "gift.fill" : "list.bullet.clipboard.fill")
                        .foregroundColor(completion.isBonus ? .green : .orange)
                        .font(.system(size: 16))
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if completion.isBonus {
                        Text("Bonus")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if isPending {
                            Text("(Pending)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Text(completion.chore?.name ?? "Unknown Chore")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if isPending {
                            Text("(Pending)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                if let date = completion.completedAt {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Show jar breakdown with color coding
                HStack(spacing: 12) {
                    if completion.spendingAmount > 0 {
                        Text("Spending: $\(completion.spendingAmount, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                    if completion.savingsAmount > 0 {
                        Text("Savings: $\(completion.savingsAmount, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    if completion.givingAmount > 0 {
                        Text("Giving: $\(completion.givingAmount, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Amount and Balance
            VStack(alignment: .trailing, spacing: 4) {
                // Transaction amount
                Text("+$\(transactionAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isPending ? .orange : .green)
                
                // Running balance (only for approved)
                if !isPending {
                    Text("Balance: $\(runningBalance, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let child = Child(context: context)
    child.name = "Claire"
    child.spendingBalance = 12.80
    child.savingsBalance = 1.60
    child.givingBalance = 1.60
    
    return NavigationView {
        ChildTransactionLedgerView(child: child)
    }
    .environment(\.managedObjectContext, context)
}
