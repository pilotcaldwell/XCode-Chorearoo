import SwiftUI
import SwiftUI
import CoreData

struct ChildrenListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Child.name, ascending: true)],
        animation: .default)
    private var children: FetchedResults<Child>
    
    @State private var showingAddChild = false
    
    private func totalBalance(for child: Child) -> Double {
        return child.spendingBalance + child.savingsBalance + child.givingBalance
    }
    
    var body: some View {
        // Use ZStack to add background gradient behind entire view
        ZStack {
            KidTheme.mainGradient // Background gradient for whole screen
            
            NavigationView {
                List {
                    ForEach(children) { child in
                        NavigationLink {
                            ChildTransactionLedgerView(child: child)
                        } label: {
                            // Card background with gradient, padding and rounded corners
                            HStack {
                                // Avatar circle with first letter of name and playful color
                                Circle()
                                    .fill(Color(hex: child.avatarColor ?? "#3b82f6"))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text(String(child.name?.prefix(1) ?? "?"))
                                            .foregroundColor(.white)
                                            .font(.title2)
                                            .bold()
                                            .shadow(color: KidTheme.purple.opacity(0.8), radius: 2) // Playful shadow on avatar letter
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(child.name ?? "Unknown")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    if child.age > 0 {
                                        Text("Age: \(child.age)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Show total balance with accent color and playful icon
                                VStack(alignment: .trailing) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .foregroundColor(KidTheme.purple)
                                        Text("$\(totalBalance(for: child), specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(KidTheme.purple)
                                            .bold()
                                    }
                                    Text("Total")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(12) // Padding inside card
                            .background(
                                KidTheme.cardGradient // Card gradient for glassy, colorful look
                            )
                            .cornerRadius(12) // Rounded corners for card
                            .shadow(color: KidTheme.purple.opacity(0.15), radius: 4, x: 0, y: 2) // Subtle shadow for elevation
                            .padding(.vertical, 4) // Space between cards
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Children")
                .toolbar {
                    Button(action: {
                        showingAddChild = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .bold()
                            .padding(8)
                            .background(KidTheme.purple) // Using KidTheme purple color for button background
                            .clipShape(Circle()) // Make button round
                            .shadow(color: KidTheme.purple.opacity(0.6), radius: 3, x: 0, y: 2) // Shadow for button
                    }
                }
                .sheet(isPresented: $showingAddChild) {
                    AddChildView()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// Helper to convert hex string to Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ChildrenListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
