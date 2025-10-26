import SwiftUI
import SwiftUI
import UIKit
import CoreData

struct ChildTransactionLedgerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var child: Child
    
    @State private var allCompletions: [ChoreCompletion] = []
    @State private var showResetAlert = false
    @State private var showBonusSheet = false
    @State private var showExpenseSheet = false
    @State private var showBonusAnimation = false
    @State private var showExpenseAnimation = false
    
    var totalBalance: Double {
        let spending = child.spendingBalance
        let savings = child.savingsBalance
        let giving = child.givingBalance
        return spending + savings + giving
    }
    
    var body: some View {
        ZStack {
            // Background gradient for whole screen - colorful and lively
            AppVibrantTheme.mainGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    balanceCard
                    actionButtons
                    transactionsSection
                    resetStatsButton
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(child.name ?? "Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchTransactions()
        }
        .sheet(isPresented: $showBonusSheet) {
            AddBonusView(child: child, onBonusAdded: {
                handleBonusAdded()
            })
        }
        .sheet(isPresented: $showExpenseSheet) {
            AddExpenseView(child: child, onExpenseAdded: {
                handleExpenseAdded()
            })
        }
        .alert("Reset All Stats?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetStats()
            }
        } message: {
            Text("This will reset all balances and clear all transaction history. This action cannot be undone.")
        }
        // Bonus animation overlay
        .overlay {
            if showBonusAnimation {
                BonusAnimationView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        // Expense animation overlay
        .overlay {
            if showExpenseAnimation {
                ExpenseAnimationView()
                    .transition(.scale.combined(with: .opacity))
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
            allCompletions = try viewContext.fetch(fetchRequest)
            print("✅ Parent ledger fetched \(allCompletions.count) approved transactions")
        } catch {
            print("❌ Error fetching transactions: \(error)")
            allCompletions = []
        }
    }
    
    private var balanceCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "banknote.fill")
                    .foregroundColor(.purple)
                Text("Total Balance")
                    .font(.headline)
                    .foregroundColor(.purple)
            }
            // Added playful icon and purple accent
            
            Text(String(format: "$%.2f", totalBalance))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.purple)
            
            jarBalances
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        // Changed background to AppVibrantTheme.cardGradient for colorful, glassy effect
        .background(AppVibrantTheme.cardGradient)
        .cornerRadius(24) // larger rounded corners for friendliness
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        .padding(.horizontal)
    }
    
    private var jarBalances: some View {
        HStack(spacing: 20) {
            VStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(.purple)
                Text("Spending")
                    .font(.caption)
                    .foregroundColor(.purple)
                Text(String(format: "$%.2f", child.spendingBalance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
            
            VStack {
                Image(systemName: "banknote.fill")
                    .foregroundColor(.green)
                Text("Savings")
                    .font(.caption)
                    .foregroundColor(.green)
                Text(String(format: "$%.2f", child.savingsBalance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            VStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(.orange)
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
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Give Bonus Button - AppVibrantTheme.greenAccent with white text, larger, rounder corners
            Button(action: {
                // Added haptic feedback on tap for better tactile experience
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showBonusSheet = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "gift.fill")
                        .font(.title2)
                    Text("Give Bonus")
                        .fontWeight(.semibold)
                        .font(.title3)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    AppVibrantTheme.greenAccent
                )
                .cornerRadius(20) // rounder corners for friendliness
                .shadow(color: AppVibrantTheme.greenAccent.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            
            // Add Expense Button - AppVibrantTheme.redAccent with white text, larger, rounder corners
            Button(action: {
                // Added haptic feedback on tap for better tactile experience
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showExpenseSheet = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                    Text("Add Expense")
                        .fontWeight(.semibold)
                        .font(.title3)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    AppVibrantTheme.redAccent
                )
                .cornerRadius(20) // rounder corners for friendliness
                .shadow(color: AppVibrantTheme.redAccent.opacity(0.5), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal)
    }
    
    private var resetStatsButton: some View {
        Button(action: {
            showResetAlert = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title2)
                Text("Reset Stats")
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            .foregroundColor(AppVibrantTheme.textOnColor) // White text for better contrast
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            // AppVibrantTheme.purpleAccent background for lively feel
            .background(AppVibrantTheme.purpleAccent)
            .cornerRadius(24) // large round corners for friendliness
            .shadow(color: AppVibrantTheme.purpleAccent.opacity(0.5), radius: 8, x: 0, y: 4)
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
                .foregroundColor(.purple)
            
            Spacer()
            
            // Show count with playful background and purple accent
            Text("\(allCompletions.count)")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppVibrantTheme.purpleAccent)
                .cornerRadius(12)
                .shadow(color: AppVibrantTheme.purpleAccent.opacity(0.5), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.5))
            Text("No transactions yet")
                .foregroundColor(.gray)
                .font(.headline)
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
        // Changed background to AppVibrantTheme.cardGradient for colorful, glassy effect
        .background(AppVibrantTheme.cardGradient)
        .cornerRadius(20) // rounder corners for friendly UI
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // Calculate running balance at a specific transaction index
    private func calculateRunningBalance(upToIndex: Int) -> Double {
        var balance = totalBalance
        
        for i in 0..<upToIndex {
            let completion = allCompletions[i]
            if completion.status == "approved" {
                let amount = completion.spendingAmount + completion.savingsAmount + completion.givingAmount
                balance -= amount
            }
        }
        
        return balance
    }
    
    private func handleBonusAdded() {
        print("🟢 Bonus added - refreshing data")
        
        // Refresh child from database
        viewContext.refresh(child, mergeChanges: true)
        
        // Re-fetch transactions
        fetchTransactions()
        
        // Show animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showBonusAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showBonusAnimation = false
            }
        }
    }
    
    private func handleExpenseAdded() {
        print("🔴 Expense added - refreshing data")
        
        // Refresh child from database
        viewContext.refresh(child, mergeChanges: true)
        
        // Re-fetch transactions
        fetchTransactions()
        
        // Show animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showExpenseAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showExpenseAnimation = false
            }
        }
    }
    
    private func resetStats() {
        child.spendingBalance = 0
        child.savingsBalance = 0
        child.givingBalance = 0
        
        for completion in allCompletions {
            viewContext.delete(completion)
        }
        
        do {
            try viewContext.save()
            fetchTransactions()
        } catch {
            print("Error resetting stats: \(error)")
        }
    }
}

// Bonus Animation View
struct BonusAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.2 : 0.5)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                
                Text("Bonus Added! 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isAnimating = true
                }
            }
        }
    }
}

// Expense Animation View
struct ExpenseAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .scaleEffect(isAnimating ? 1.2 : 0.5)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                
                Text("Expense Recorded 💸")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isAnimating = true
                }
            }
        }
    }
}

struct ParentTransactionRow: View {
    let completion: ChoreCompletion
    let child: Child
    let runningBalance: Double
    
    var isExpense: Bool {
        let totalAmount = completion.spendingAmount + completion.savingsAmount + completion.givingAmount
        return totalAmount < 0
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
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isExpense ? Color.red.opacity(0.2) : (completion.isBonus ? Color.green.opacity(0.2) : Color.orange.opacity(0.2)))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isExpense ? "minus.circle.fill" : (completion.isBonus ? "gift.fill" : "list.bullet.clipboard.fill"))
                        .foregroundColor(isExpense ? .red : (completion.isBonus ? .green : .orange))
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if isExpense {
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
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(isExpense ? "-" : "+")$\(transactionAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isExpense ? .red : (isPending ? .orange : .green))
                
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