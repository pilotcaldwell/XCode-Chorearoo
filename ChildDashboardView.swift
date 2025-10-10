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
    
    // Add state for selected tab and refresh trigger
    @State private var selectedTab = 0
    @State private var refreshID = UUID()
    @State private var allTransactions: [ChoreCompletion] = []
    
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
        print("🟡 Calculating thisWeekChoreEarnings")
        print("🟡 Number of pending completions: \(pendingCompletions.count)")
        for completion in pendingCompletions {
            print("🟡 Found pending: \(completion.chore?.name ?? "unknown") - $\(completion.chore?.amount ?? 0)")
            print("🟡   Week start: \(completion.weekStartDate ?? Date())")
            print("🟡   Status: \(completion.status ?? "no status")")
        }
        let total = pendingCompletions.reduce(0) { $0 + ($1.chore?.amount ?? 0) }
        print("🟡 Total thisWeekChoreEarnings: $\(total)")
        return total
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
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            dashboardContent
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            // Chores Tab
            ChildChoreListView(child: child, refreshTrigger: $refreshID)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Chores")
                }
                .tag(1)
            
            // Store Tab
            ChildStoreView(child: child)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Store")
                }
                .tag(2)
        }
        .onAppear {
            fetchTransactions()
        }
        .onChange(of: selectedTab) {
            // Refresh transactions when switching back to dashboardf
            if selectedTab == 0 {
                fetchTransactions()
            }
        }
    }
    
    private func fetchTransactions() {
        let fetchRequest: NSFetchRequest<ChoreCompletion> = ChoreCompletion.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)]
        
        if let childId = child.id?.uuidString {
            // ONLY fetch approved transactions (no pending ones)
            fetchRequest.predicate = NSPredicate(format: "child.id == %@ AND status == %@",
                                                childId as CVarArg,
                                                "approved")
        }
        
        do {
            allTransactions = try viewContext.fetch(fetchRequest)
            print("✅ Child dashboard fetched \(allTransactions.count) approved transactions")
        } catch {
            print("❌ Error fetching transactions: \(error)")
            allTransactions = []
        }
    }
    
    private var dashboardContent: some View {
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
                    .id(refreshID)
                    
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
    
    // ... [Continue in Part 2]
    // ... [Continued from Part 1]
        
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

    // ... [Continue in Part 3 for helper views]
// ... [Continued - Helper Views and Components]

// New Child Chore List View with Pending Status
struct ChildChoreListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let child: Child
    @Binding var refreshTrigger: UUID
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chore.name, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default)
    private var chores: FetchedResults<Chore>
    
    @FetchRequest private var pendingCompletions: FetchedResults<ChoreCompletion>
    
    @State private var selectedChore: Chore?
    @State private var showCapReachedAlert = false
    @State private var pendingChoreIDs: Set<UUID> = []
    
    init(child: Child, refreshTrigger: Binding<UUID>) {
        self.child = child
        self._refreshTrigger = refreshTrigger
        
        let childId = child.id?.uuidString ?? ""
        let weekStart = Self.getStartOfWeek()
        _pendingCompletions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ChoreCompletion.completedAt, ascending: false)],
            predicate: NSPredicate(format: "child.id == %@ AND status == %@ AND weekStartDate == %@ AND isBonus == NO",
                                 childId as CVarArg, "pending", weekStart as CVarArg),
            animation: .default
        )
    }
    
    static func getStartOfWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components) ?? now
    }
    
    var thisWeekEarnings: Double {
        pendingCompletions.reduce(0) { $0 + ($1.chore?.amount ?? 0) }
    }
    
    var remainingCapacity: Double {
        max(0, child.weeklyCap - thisWeekEarnings)
    }
    
    // Check if a chore is pending
    func isPending(chore: Chore) -> Bool {
        guard let choreId = chore.id else { return false }
        
        // Check our local state first
        if pendingChoreIDs.contains(choreId) {
            return true
        }
        
        // Check the database
        return pendingCompletions.contains { $0.chore?.id == choreId }
    }
    
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This week: $\(thisWeekEarnings, specifier: "%.2f") of $\(child.weeklyCap, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        ProgressView(value: thisWeekEarnings, total: child.weeklyCap)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    List(chores) { chore in
                        ChoreRowWithStatus(
                            chore: chore,
                            isPending: isPending(chore: chore),
                            wouldExceedCap: wouldExceedCap(chore),
                            onTap: {
                                handleChoreSelection(chore)
                            }
                        )
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Complete Chore")
            .alert("Weekly Cap Reached", isPresented: $showCapReachedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You've reached your weekly earning cap of $\(child.weeklyCap, specifier: "%.2f"). Ask a parent for a bonus or wait until next week!")
            }
        }
    }
    
    private func wouldExceedCap(_ chore: Chore) -> Bool {
        return (thisWeekEarnings + chore.amount) > child.weeklyCap
    }
    
    private func handleChoreSelection(_ chore: Chore) {
        if isPending(chore: chore) {
            // Do nothing if already pending
            return
        }
        
        if wouldExceedCap(chore) {
            showCapReachedAlert = true
        } else {
            // Complete immediately without confirmation
            completeChore(chore)
        }
    }
    
    private func completeChore(_ chore: Chore) {
        print("🔵 Starting to complete chore: \(chore.name ?? "unknown")")
        
        // Immediately mark as pending in local state
        if let choreId = chore.id {
            pendingChoreIDs.insert(choreId)
        }
        
        let completion = ChoreCompletion(context: viewContext)
        completion.id = UUID()
        completion.status = "pending"
        completion.completedAt = Date()
        completion.weekStartDate = Self.getStartOfWeek()
        completion.isBonus = false
        
        // DEBUG: Print what we're setting
        print("🔵 Week start date: \(Self.getStartOfWeek())")
        print("🔵 Chore amount: $\(chore.amount)")
        
        let total = chore.amount
        completion.spendingAmount = total * 0.8
        completion.savingsAmount = total * 0.1
        completion.givingAmount = total * 0.1
        
        completion.child = child
        completion.chore = chore
        
        print("🔵 Created completion with status: \(completion.status ?? "nil")")
        print("🔵 Child: \(child.name ?? "unknown")")
        print("🔵 Chore: \(chore.name ?? "unknown")")
        
        do {
            try viewContext.save()
            print("✅ Successfully saved to Core Data")
            
            // UI will refresh automatically due to @FetchRequest
            
            // Trigger refresh of dashboard
            refreshTrigger = UUID()
        } catch {
            print("❌ Error completing chore: \(error)")
            // Remove from pending if save failed
            if let choreId = chore.id {
                pendingChoreIDs.remove(choreId)
            }
            
            // Trigger refresh of dashboard
            refreshTrigger = UUID()
        }
    }
}

// Custom row that shows pending status
struct ChoreRowWithStatus: View {
    let chore: Chore
    let isPending: Bool
    let wouldExceedCap: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
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
                
                // Show amount
                Text("$\(chore.amount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(wouldExceedCap ? .red : .green)
            }
            .padding(.vertical, 8)
            
            // Button at the bottom
            Button(action: {
                print("🟣 BUTTON TAPPED for chore: \(chore.name ?? "unknown")")
                print("🟣 isPending: \(isPending)")
                print("🟣 wouldExceedCap: \(wouldExceedCap)")
                onTap()
            }) {
                HStack(spacing: 8) {
                    if isPending {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                        Text("Pending")
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("I Did It!")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isPending ? Color.gray : (wouldExceedCap ? Color.red.opacity(0.5) : Color.purple))
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isPending || wouldExceedCap)
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

// ... [Continue in Part 4 for remaining helper views]
// ... [Final helper views and components]

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
    
    // Check if this is an expense (negative amounts) or purchase
    var isExpense: Bool {
        let totalAmount = completion.spendingAmount + completion.savingsAmount + completion.givingAmount
        return totalAmount < 0
    }
    
    var isPurchase: Bool {
        return isExpense && (completion.chore?.name?.hasPrefix("Purchase:") ?? false)
    }
    
    var transactionAmount: Double {
        if completion.isBonus {
            return completion.spendingAmount + completion.savingsAmount + completion.givingAmount
        } else if isExpense {
            return abs(completion.spendingAmount + completion.savingsAmount + completion.givingAmount)
        } else {
            return completion.chore?.amount ?? 0
        }
    }
    
    var isPending: Bool {
        completion.status == "pending"
    }
    
    var displayIcon: String {
        if isPurchase {
            return "cart.fill"
        } else if isExpense {
            return "minus.circle.fill"
        } else if completion.isBonus {
            return "gift.fill"
        } else {
            return "list.bullet.clipboard.fill"
        }
    }
    
    var displayColor: Color {
        if isPurchase {
            return .blue
        } else if isExpense {
            return .red
        } else if completion.isBonus {
            return .green
        } else {
            return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(displayColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: displayIcon)
                        .foregroundColor(displayColor)
                        .font(.system(size: 16))
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if isPurchase {
                        Text(completion.chore?.name?.replacingOccurrences(of: "Purchase: ", with: "") ?? "Purchase")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else if isExpense {
                        Text(completion.chore?.name?.replacingOccurrences(of: "Expense: ", with: "") ?? "Expense")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else if completion.isBonus {
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
                    if completion.spendingAmount != 0 {
                        Text("Spending: $\(abs(completion.spendingAmount), specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                    if completion.savingsAmount != 0 {
                        Text("Savings: $\(abs(completion.savingsAmount), specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    if completion.givingAmount != 0 {
                        Text("Giving: $\(abs(completion.givingAmount), specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Amount and Balance
            VStack(alignment: .trailing, spacing: 4) {
                // Transaction amount - show + for income, - for expense
                Text("\(isExpense ? "-" : "+")$\(transactionAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isExpense ? .red : (isPending ? .orange : .green))
                
                // Running balance (only for approved transactions)
                if !isPending {
                    Text("Balance: $\(runningBalance, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            // Do nothing - transactions shouldn't be clickable
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
