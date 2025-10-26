import SwiftUI
import CoreData

struct ChildStoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var child: Child
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreItem.name, ascending: true)],
        predicate: NSPredicate(format: "isAvailable == YES"),
        animation: .default)
    private var storeItems: FetchedResults<StoreItem>
    
    @State private var selectedItem: StoreItem?
    @State private var showPurchaseSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // System default background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // My Money Card
                        myMoneyCard
                        
                        // Store Items
                        if storeItems.isEmpty {
                            emptyStoreView
                        } else {
                            itemsGrid
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🛒 Store")
            .sheet(item: $selectedItem) { item in
                PurchaseItemView(
                    child: child,
                    item: item,
                    onPurchase: {
                        selectedItem = nil
                    }
                )
            }
        }
    }
    
    private var myMoneyCard: some View {
        VStack(spacing: 12) {
            Text("My Shopping Money")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack {
                    Text("💰")
                        .font(.title)
                    Text("$\(child.spendingBalance, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Spending")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack {
                    Text("🏦")
                        .font(.title)
                    Text("$\(child.savingsBalance, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Savings")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    private var emptyStoreView: some View {
        VStack(spacing: 20) {
            Text("🏪")
                .font(.system(size: 80))
            Text("Store is Empty!")
                .font(.title2)
                .fontWeight(.bold)
            Text("Ask a parent to add items to the store")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
    
    private var itemsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(storeItems) { item in
                StoreItemCard(item: item, child: child) {
                    selectedItem = item
                }
            }
        }
    }
}

struct StoreItemCard: View {
    let item: StoreItem
    let child: Child
    let onTap: () -> Void
    
    var canAfford: Bool {
        let availableMoney = child.spendingBalance + child.savingsBalance
        return availableMoney >= item.price
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: item.imageName ?? "gift.fill")
                    .font(.system(size: 40))
                    .foregroundColor(canAfford ? .blue : .gray)
                    .frame(height: 60)
                
                // Name
                Text(item.name ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 40)
                
                // Price
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(canAfford ? .green : .red)
                
                if !canAfford {
                    Text("Can't afford")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5)
            .opacity(canAfford ? 1.0 : 0.6)
        }
        .disabled(!canAfford)
    }
}

struct PurchaseItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var child: Child
    let item: StoreItem
    let onPurchase: () -> Void
    
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showSuccessAnimation = false
    
    enum PaymentMethod: String {
        case spending = "Spending"
        case savings = "Savings"
        case both = "Both"
    }
    
    var availablePaymentMethods: [PaymentMethod] {
        var methods: [PaymentMethod] = []
        
        if item.price <= child.spendingBalance {
            methods.append(.spending)
        }
        
        if item.price <= child.savingsBalance {
            methods.append(.savings)
        }
        
        if item.price > child.spendingBalance &&
           item.price > child.savingsBalance &&
           item.price <= (child.spendingBalance + child.savingsBalance) {
            methods.append(.both)
        }
        
        return methods
    }
    
    var spendingNeeded: Double {
        return min(item.price, child.spendingBalance)
    }
    
    var savingsNeeded: Double {
        return item.price - spendingNeeded
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 25) {
                        // Item Display
                        VStack(spacing: 15) {
                            Image(systemName: item.imageName ?? "gift.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text(item.name ?? "Unknown")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let description = item.itemDescription, !description.isEmpty {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Text("$\(item.price, specifier: "%.2f")")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding()
                        
                        // Payment Method Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Choose how to pay:")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach([PaymentMethod.spending, .savings, .both], id: \.self) { method in
                                PaymentMethodButton(
                                    method: method,
                                    isAvailable: availablePaymentMethods.contains(method),
                                    isSelected: selectedPaymentMethod == method,
                                    spendingAmount: method == .both ? spendingNeeded : nil,
                                    savingsAmount: method == .both ? savingsNeeded : nil
                                ) {
                                    if availablePaymentMethods.contains(method) {
                                        selectedPaymentMethod = method
                                    }
                                }
                            }
                        }
                        
                        // Buy Button
                        if selectedPaymentMethod != nil {
                            Button(action: {
                                makePurchase()
                            }) {
                                Text("Buy Now! 🎉")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.green, Color.blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(15)
                                    .shadow(color: .green.opacity(0.3), radius: 10)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Success Animation
                if showSuccessAnimation {
                    PurchaseSuccessView(itemName: item.name ?? "Item")
                }
            }
            .navigationTitle("Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func makePurchase() {
        guard let paymentMethod = selectedPaymentMethod else { return }
        
        // Deduct money based on payment method
        switch paymentMethod {
        case .spending:
            child.spendingBalance -= item.price
        case .savings:
            child.savingsBalance -= item.price
        case .both:
            child.spendingBalance -= spendingNeeded
            child.savingsBalance -= savingsNeeded
        }
        
        // Create purchase record (as an expense)
        let purchase = ChoreCompletion(context: viewContext)
        purchase.id = UUID()
        purchase.status = "approved"
        purchase.completedAt = Date()
        purchase.approvedAt = Date()
        purchase.weekStartDate = getStartOfWeek()
        purchase.isBonus = false
        
        // Store as negative amounts (expense)
        switch paymentMethod {
        case .spending:
            purchase.spendingAmount = -item.price
            purchase.savingsAmount = 0
            purchase.givingAmount = 0
        case .savings:
            purchase.spendingAmount = 0
            purchase.savingsAmount = -item.price
            purchase.givingAmount = 0
        case .both:
            purchase.spendingAmount = -spendingNeeded
            purchase.savingsAmount = -savingsNeeded
            purchase.givingAmount = 0
        }
        
        // Create chore record for the purchase
        let purchaseChore = Chore(context: viewContext)
        purchaseChore.id = UUID()
        purchaseChore.name = "Purchase: \(item.name ?? "Item")"
        purchaseChore.amount = item.price
        purchaseChore.isActive = false
        purchaseChore.createdAt = Date()
        
        purchase.chore = purchaseChore
        purchase.child = child
        
        do {
            try viewContext.save()
            
            // Show success animation
            withAnimation {
                showSuccessAnimation = true
            }
            
            // Dismiss after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onPurchase()
                dismiss()
            }
        } catch {
            print("Error making purchase: \(error)")
        }
    }
    
    private func getStartOfWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components) ?? now
    }
}

struct PaymentMethodButton: View {
    let method: PurchaseItemView.PaymentMethod
    let isAvailable: Bool
    let isSelected: Bool
    let spendingAmount: Double?
    let savingsAmount: Double?
    let action: () -> Void
    
    var icon: String {
        switch method {
        case .spending: return "💰"
        case .savings: return "🏦"
        case .both: return "💰🏦"
        }
    }
    
    var unavailableMessage: String {
        switch method {
        case .spending, .savings:
            return "Not enough money"
        case .both:
            return "Not needed"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.rawValue)
                        .font(.headline)
                        .foregroundColor(isAvailable ? .primary : .gray)
                    
                    if method == .both, let spending = spendingAmount, let savings = savingsAmount {
                        Text("$\(spending, specifier: "%.2f") + $\(savings, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if !isAvailable {
                        Text(unavailableMessage)
                            .font(.caption)
                            .foregroundColor(method == .both ? .gray : .red)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
            .opacity(isAvailable ? 1.0 : 0.5)
        }
        .disabled(!isAvailable)
        .padding(.horizontal)
    }
}

struct PurchaseSuccessView: View {
    let itemName: String
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 100))
                    .scaleEffect(isAnimating ? 1.2 : 0.5)
                
                Text("You bought it!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(itemName)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
            }
            .opacity(isAnimating ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let child = Child(context: context)
    child.spendingBalance = 15.0
    child.savingsBalance = 10.0
    
    return ChildStoreView(child: child)
        .environment(\.managedObjectContext, context)
}
