import SwiftUI
import UIKit
import CoreData

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let child: Child
    let onExpenseAdded: () -> Void  // Callback when expense is successfully added
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedJar: MoneyJar = .spending
    @State private var showInsufficientFundsAlert = false
    
    enum MoneyJar: String, CaseIterable, Identifiable {
        case spending = "Spending"
        case savings = "Savings"
        case giving = "Giving"
        
        var id: String { self.rawValue }
    }
    
    // Check if child has enough money in selected jar
    var hasEnoughMoney: Bool {
        guard let expenseAmount = Double(amount), expenseAmount > 0 else { return true }
        
        switch selectedJar {
        case .spending:
            return child.spendingBalance >= expenseAmount
        case .savings:
            return child.savingsBalance >= expenseAmount
        case .giving:
            return child.givingBalance >= expenseAmount
        }
    }
    
    var currentJarBalance: Double {
        switch selectedJar {
        case .spending:
            return child.spendingBalance
        case .savings:
            return child.savingsBalance
        case .giving:
            return child.givingBalance
        }
    }
    
    var body: some View {
        NavigationView {
            // Changed from Form to ScrollView and VStack with glassy background for a modern look
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        Text("Expense Details")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                        
                        HStack {
                            Text("Child:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(child.name ?? "Unknown")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("$")
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Picker("Money Jar", selection: $selectedJar) {
                            ForEach(MoneyJar.allCases) { jar in
                                Text(jar.rawValue).tag(jar)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text("Current Balance:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("$\(currentJarBalance, specifier: "%.2f")")
                                .foregroundColor(hasEnoughMoney ? .primary : .red)
                                .fontWeight(.semibold)
                        }
                        
                        TextField("Description (e.g., Bought toy)", text: $description)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    if !hasEnoughMoney {
                        Text("⚠️ Insufficient funds in \(selectedJar.rawValue) jar")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text("💡 This will deduct money from \(child.name ?? "child")'s account and appear in their transaction history.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Record Expense") {
                        recordExpense()
                    }
                    .disabled(amount.isEmpty || description.isEmpty || !hasEnoughMoney)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial) // glassy background
                .cornerRadius(20)
                .padding()
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Not enough money in the \(selectedJar.rawValue) jar.")
            }
        }
    }
    
    private func recordExpense() {
        guard let expenseAmount = Double(amount), expenseAmount > 0 else { return }
        guard !description.isEmpty else { return }
        
        print("🔴 Starting to record expense")
        print("🔴 Amount: $\(expenseAmount)")
        print("🔴 Description: \(description)")
        print("🔴 Jar: \(selectedJar.rawValue)")
        
        // Double-check funds
        if !hasEnoughMoney {
            showInsufficientFundsAlert = true
            return
        }
        
        // Deduct money from the appropriate jar
        switch selectedJar {
        case .spending:
            child.spendingBalance -= expenseAmount
        case .savings:
            child.savingsBalance -= expenseAmount
        case .giving:
            child.givingBalance -= expenseAmount
        }
        
        // Create a special "expense" completion record for tracking
        let expense = ChoreCompletion(context: viewContext)
        expense.id = UUID()
        expense.status = "approved"
        expense.completedAt = Date()
        expense.approvedAt = Date()
        expense.weekStartDate = getStartOfWeek()
        expense.isBonus = false
        
        // Store amounts as NEGATIVE to indicate expense
        switch selectedJar {
        case .spending:
            expense.spendingAmount = -expenseAmount
            expense.savingsAmount = 0
            expense.givingAmount = 0
        case .savings:
            expense.spendingAmount = 0
            expense.savingsAmount = -expenseAmount
            expense.givingAmount = 0
        case .giving:
            expense.spendingAmount = 0
            expense.savingsAmount = 0
            expense.givingAmount = -expenseAmount
        }
        
        // Create a special "expense" chore record to store the description
        let expenseChore = Chore(context: viewContext)
        expenseChore.id = UUID()
        expenseChore.name = "Expense: \(description)"
        expenseChore.amount = expenseAmount
        expenseChore.isActive = false
        expenseChore.createdAt = Date()
        
        expense.chore = expenseChore
        expense.child = child
        
        do {
            try viewContext.save()
            print("✅ Successfully saved expense to Core Data")
            
            // Provide gentle vibration feedback on expense recording
            UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Haptic feedback for button press
            
            // Dismiss first
            dismiss()
            
            // Then trigger callback after a short delay to ensure UI updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onExpenseAdded()
            }
        } catch {
            print("❌ Error recording expense: \(error)")
        }
    }
    
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
    child.spendingBalance = 10.0
    child.savingsBalance = 5.0
    child.givingBalance = 3.0
    
    return AddExpenseView(child: child, onExpenseAdded: {})
        .environment(\.managedObjectContext, context)
}
