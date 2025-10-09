import SwiftUI
import CoreData

struct ChildDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let child: Child
    
    // Add these two bindings to control authentication
    @Binding var isAuthenticated: Bool
    @Binding var userRole: UserRole?
    
    @FetchRequest private var approvedCompletions: FetchedResults<ChoreCompletion>
    @FetchRequest private var pendingCompletions: FetchedResults<ChoreCompletion>
    @FetchRequest private var thisWeekApprovedBonuses: FetchedResults<ChoreCompletion>
    
    init(child: Child, isAuthenticated: Binding<Bool>, userRole: Binding<UserRole?>) {
        self.child = child
        self._isAuthenticated = isAuthenticated
        self._userRole = userRole
        
        let childId = child.id?.uuidString ?? ""
        _approvedCompletions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
            predicate: NSPredicate(format: "child.id == %@ AND status == %@", childId as CVarArg, "approved"),
            animation: .default
        )
        
        // Fetch pending chore completions for this week (not bonuses)
        let weekStart = Self.getStartOfWeek()
        _pendingCompletions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
            predicate: NSPredicate(format: "child.id == %@ AND status == %@ AND weekStartDate == %@ AND isBonus == NO",
                                 childId as CVarArg, "pending", weekStart as CVarArg),
            animation: .default
        )
        
        // Fetch approved bonuses for this week
        _thisWeekApprovedBonuses = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
            predicate: NSPredicate(format: "child.id == %@ AND status == %@ AND weekStartDate == %@ AND isBonus == YES",
                                 childId as CVarArg, "approved", weekStart as CVarArg),
            animation: .default
        )
    }
    
    static func getStartOfWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components) ?? now
    }
    
    var thisWeekChoreEarnings: Double {
        pendingCompletions
            .reduce(0) { $0 + ($1.chore?.amount ?? 0) }
    }
    
    var thisWeekBonusEarnings: Double {
        thisWeekApprovedBonuses
            .reduce(0) { $0 + $1.spendingAmount + $1.savingsAmount + $1.givingAmount }
    }
    
    var totalBalance: Double {
        child.spendingBalance + child.savingsBalance + child.givingBalance
    }
    
    var todayCompletionCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let filtered = approvedCompletions.filter { completion in
            guard let completedAt = completion.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: today)
        }
        return filtered.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Balance Card (FIRST - biggest)
                    totalBalanceCard
                    
                    // Money Jars Section (SECOND)
                    moneyJarsSection
                    
                    // Weekly Progress Card (THIRD)
                    WeeklyProgressCard(
                        child: child,
                        choreEarnings: thisWeekChoreEarnings,
                        bonusEarnings: thisWeekBonusEarnings,
                        weeklyCap: child.weeklyCap > 0 ? child.weeklyCap : 10.0
                    )
                    
                    // Stats Cards
                    statsCardsSection
                    
                    // Transaction Ledger (replacing Recent Transactions)
                    transactionLedgerSection
                    
                    // Logout Button at Bottom
                    Button(action: {
                        isAuthenticated = false
                        userRole = nil
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                        .padding(.vertical, 16)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle(child.name ?? "Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var totalBalanceCard: some View {
        VStack(spacing: 8) {
            Text("My Cash Balance")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(String(format: "$%.2f", totalBalance))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.purple)
            
            Text("Total across all three money jars")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private var moneyJarsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.purple)
                Text("My Money Jars")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                MoneyJarCard(
                    title: "Spending (80%)",
                    subtitle: "For things I want",
                    amount: child.spendingBalance,
                    color: .purple
                )
                
                MoneyJarCard(
                    title: "Savings (10%)",
                    subtitle: "For my future",
                    amount: child.savingsBalance,
                    color: .green
                )
                
                MoneyJarCard(
                    title: "Giving (10%)",
                    subtitle: "To help others",
                    amount: child.givingBalance,
                    color: .orange
                )
            }
            .padding(.horizontal)
            
            Text("Every time you earn money, it's automatically split into these three jars!")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var statsCardsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "trophy.fill",
                title: "Total Earned",
                value: String(format: "$%.2f", totalBalance),
                subtitle: "Since you started",
                color: .orange
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Today",
                value: "\(todayCompletionCount)",
                subtitle: "Chores completed",
                color: .green
            )
        }
        .padding(.horizontal)
    }
    
    private var transactionLedgerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.purple)
                Text("Transactions")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            if allTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No transactions yet")
                        .foregroundColor(.gray)
                    Text("Complete some chores to get started!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(allTransactions.enumerated()), id: \.element.id) { index, completion in
                        TransactionLedgerRow(
                            completion: completion,
                            child: child,
                            runningBalance: calculateRunningBalance(upToIndex: index)
                        )
                        
                        if completion.id != allTransactions.last?.id {
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
        }
        .padding(.vertical)
    }
    
    // Get all transactions (pending + approved), sorted by date
    var allTransactions: [ChoreCompletion] {
        let pending = Array(pendingCompletions)
        let approved = approvedCompletions.filter { completion in
            // Only show recent approved transactions (last 30 days)
            guard let completedAt = completion.completedAt else { return false }
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return completedAt >= thirtyDaysAgo
        }
        
        return (pending + approved).sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
    }
    
    // Calculate running balance at a specific transaction index
    private func calculateRunningBalance(upToIndex: Int) -> Double {
        // Start with current total balance
        var balance = totalBalance
        
        // Subtract all transactions that came AFTER this one (going backwards in time)
        // Since transactions are sorted newest first, we subtract transactions at indices 0 to upToIndex-1
        for i in 0..<upToIndex {
            let completion = allTransactions[i]
            if completion.status == "approved" {
                let amount = completion.spendingAmount + completion.savingsAmount + completion.givingAmount
                balance -= amount
            }
        }
        
        return balance
    }
}

struct MoneyJarCard: View {
    let title: String
    let subtitle: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(String(format: "$%.2f", amount))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct TransactionLedgerRow: View {
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
                
                // Show jar breakdown with color coding (no emojis)
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
                Text(isPending ? "+$\(transactionAmount, specifier: "%.2f")" : "+$\(transactionAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isPending ? .orange : .green)
                
                // Running balance (only for approved transactions)
                if !isPending {
                    Text("Balance: $\(runningBalance, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .contentShape(Rectangle()) // Makes entire row tappable area
        .onTapGesture {
            // Do nothing - transactions shouldn't be clickable
        }
    }
}

struct TransactionRow: View {
    let completion: ChoreCompletion
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(completion.isBonus ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: completion.isBonus ? "gift.fill" : "list.bullet.clipboard.fill")
                        .foregroundColor(completion.isBonus ? .green : .orange)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                if completion.isBonus {
                    Text("Bonus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Show which jar the bonus went to
                    if completion.spendingAmount > 0 {
                        Text("Spending jar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if completion.savingsAmount > 0 {
                        Text("Savings jar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if completion.givingAmount > 0 {
                        Text("Giving jar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(completion.chore?.name ?? "Unknown Chore")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let date = completion.completedAt {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            TransactionAmountView(completion: completion)
        }
        .padding()
    }
}

struct TransactionAmountView: View {
    let completion: ChoreCompletion
    
    var transactionAmount: Double {
        if completion.isBonus {
            return completion.spendingAmount + completion.savingsAmount + completion.givingAmount
        } else {
            return completion.chore?.amount ?? 0
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(String(format: "+$%.2f", transactionAmount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            
            if let child = completion.child {
                let total = child.spendingBalance + child.savingsBalance + child.givingBalance
                Text(String(format: "Balance: $%.2f", total))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let child = Child(context: context)
    child.id = UUID()
    child.name = "Claire"
    child.spendingBalance = 12.80
    child.savingsBalance = 1.60
    child.givingBalance = 1.60
    
    return ChildDashboardView(
        child: child,
        isAuthenticated: .constant(true),
        userRole: .constant(.child(child))
    )
    .environment(\.managedObjectContext, context)
}
