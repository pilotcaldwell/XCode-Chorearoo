import SwiftUI
import CoreData

struct AddBonusView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let child: Child
    
    @State private var amount: String = ""
    @State private var reason: String = ""
    @State private var selectedJar: MoneyJar = .spending
    
    enum MoneyJar: String, CaseIterable, Identifiable {
        case spending = "Spending"
        case savings = "Savings"
        case giving = "Giving"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bonus Details")) {
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
                    }
                    
                    Picker("Money Jar", selection: $selectedJar) {
                        ForEach(MoneyJar.allCases) { jar in
                            Text(jar.rawValue).tag(jar)
                        }
                    }
                    
                    TextField("Reason (optional)", text: $reason)
                }
                
                Section {
                    Text("💡 Bonuses are instantly added and don't count against the weekly cap!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button("Give Bonus") {
                        giveBonus()
                    }
                    .disabled(amount.isEmpty)
                }
            }
            .navigationTitle("Add Bonus")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
    
    private func giveBonus() {
        guard let bonusAmount = Double(amount), bonusAmount > 0 else { return }
        
        // Add money directly to child's balance (no ChoreCompletion needed for tracking)
        switch selectedJar {
        case .spending:
            child.spendingBalance += bonusAmount
        case .savings:
            child.savingsBalance += bonusAmount
        case .giving:
            child.givingBalance += bonusAmount
        }
        
        // Create a completion record for transaction history only
        let bonus = ChoreCompletion(context: viewContext)
        bonus.id = UUID()
        bonus.status = "approved"
        bonus.completedAt = Date()
        bonus.approvedAt = Date()
        bonus.weekStartDate = getStartOfWeek()
        bonus.isBonus = true
        
        // Store amounts for display purposes
        switch selectedJar {
        case .spending:
            bonus.spendingAmount = bonusAmount
            bonus.savingsAmount = 0
            bonus.givingAmount = 0
        case .savings:
            bonus.spendingAmount = 0
            bonus.savingsAmount = bonusAmount
            bonus.givingAmount = 0
        case .giving:
            bonus.spendingAmount = 0
            bonus.savingsAmount = 0
            bonus.givingAmount = bonusAmount
        }
        
        bonus.child = child
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error giving bonus: \(error)")
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
    
    return AddBonusView(child: child)
        .environment(\.managedObjectContext, context)
}
