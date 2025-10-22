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
        NavigationView {
            List {
                ForEach(children) { child in
                    NavigationLink {
                        ChildTransactionLedgerView(child: child)
                    } label: {
                        // Clean card design with excellent contrast
                        HStack(spacing: 16) {
                            // Avatar circle with first letter of name
                            Circle()
                                .fill(Color(hex: child.avatarColor ?? "#3b82f6"))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(String(child.name?.prefix(1) ?? "?"))
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .bold()
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(child.name ?? "Unknown")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(KidTheme.textPrimary)
                                
                                if child.age > 0 {
                                    Text("Age: \(child.age)")
                                        .font(.subheadline)
                                        .foregroundColor(KidTheme.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Show total balance with fun styling
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text("💰")
                                        .font(.title2)
                                    Text("$\(totalBalance(for: child), specifier: "%.2f")")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(KidTheme.green)
                                }
                                Text("Total Saved")
                                    .font(.caption)
                                    .foregroundColor(KidTheme.textSecondary)
                            }
                        }
                        .padding(20)
                        .background(KidTheme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(KidTheme.purple.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .background(KidTheme.backgroundSecondary)
            .navigationTitle("My Kids 👨‍👩‍👧‍👦")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddChild = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                            Text("Add Kid")
                        }
                        .font(.headline)
                        .foregroundColor(KidTheme.textOnColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(KidTheme.purple)
                        .cornerRadius(25)
                        .shadow(color: KidTheme.purple.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
