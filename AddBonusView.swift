import SwiftUI
import UIKit // Import UIKit for haptic feedback
import CoreData

struct AddBonusView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let child: Child
    let onBonusAdded: () -> Void  // Callback when bonus is successfully added
    
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
        ZStack {
            Color(.systemBackground) // System default background
            .ignoresSafeArea() // System background fills screen
            
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        Section(header:
                                    Text("Bonus Details")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.green) // Brighten header with AppTheme green
                        ) {
                            HStack {
                                Text("Child:")
                                    .foregroundColor(AppTheme.yellow) // Accent color for labels
                                Spacer()
                                Text(child.name ?? "Unknown")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.orange) // Accent child name
                            }
                            
                            HStack {
                                Text("$")
                                    .foregroundColor(AppTheme.purple) // Accent $ symbol
                                TextField("Amount", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            
                            Picker("Money Jar", selection: $selectedJar) {
                                ForEach(MoneyJar.allCases) { jar in
                                    Text(jar.rawValue).tag(jar)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .tint(AppTheme.green) // Tint segmented picker with AppTheme green
                            
                            TextField("Reason (optional)", text: $reason)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Section {
                            Text("💡 Bonuses are instantly added and don't count against the weekly cap!")
                                .font(.caption)
                                .foregroundColor(AppTheme.yellow.opacity(0.8)) // Accent info text
                        }
                        
                        Section {
                            Button {
                                giveBonus()
                            } label: {
                                Text("Give Bonus")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.green) // Prominent button background
                                    .foregroundColor(.white) // White text for contrast
                                    .cornerRadius(12) // Rounded corners
                            }
                            .disabled(amount.isEmpty)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20) // Modern card effect
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
                    )
                    .padding()
                }
                .navigationTitle("Add Bonus")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.orange) // Bright cancel button color
                )
            }
        }
    }
    
    private func giveBonus() {
        guard let bonusAmount = Double(amount), bonusAmount > 0 else { return }
        
        print("🟢 Starting to give bonus")
        print("🟢 Amount: $\(bonusAmount)")
        print("🟢 Jar: \(selectedJar.rawValue)")
        
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
        bonus.status = "approved" // Immediately approved since parent is doing it
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
            print("✅ Successfully saved bonus to Core Data")
            
            // Provide gentle vibration feedback for button press
            UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Haptic feedback
            
            // Dismiss first
            dismiss()
            
            // Then trigger callback after a short delay to ensure UI updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onBonusAdded()
            }
        } catch {
            print("❌ Error giving bonus: \(error)")
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
    
    return AddBonusView(child: child, onBonusAdded: {})
        .environment(\.managedObjectContext, context)
}
