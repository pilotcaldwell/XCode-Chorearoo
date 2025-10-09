import SwiftUI
import CoreData

struct ChildDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let child: Child
    
    // Add these two bindings to control authentication
    @Binding var isAuthenticated: Bool
    @Binding var userRole: UserRole?
    
    @FetchRequest private var approvedCompletions: FetchedResults<ChoreCompletion>
    
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
                    // Total Balance Card
                    totalBalanceCard
                    
                    // Money Jars Section
                    moneyJarsSection
                    
                    // Stats Cards
                    statsCardsSection
                    
                    // Recent Transactions
                    recentTransactionsSection
                    
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
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.purple)
                Text("Recent Transactions")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            if approvedCompletions.isEmpty {
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
                    ForEach(Array(approvedCompletions.prefix(5))) { completion in
                        TransactionRow(completion: completion)
                        
                        if completion.id != approvedCompletions.prefix(5).last?.id {
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
                Text("$\(amount, format: .currency(code: "USD"))")
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

struct TransactionRow: View {
    let completion: ChoreCompletion
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "list.bullet.clipboard.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(completion.chore?.name ?? "Unknown Chore")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let date = completion.completedAt {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
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
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if let amount = completion.chore?.amount {
                Text(String(format: "+$%.2f", amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
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
