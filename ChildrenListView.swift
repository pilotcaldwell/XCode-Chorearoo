import SwiftUI
import CoreData

struct ChildrenListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Child.name, ascending: true)],
        animation: .default)
    private var children: FetchedResults<Child>
    
    @State private var showingAddChild = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(children) { child in
                    NavigationLink {
                        ChildTransactionLedgerView(child: child)
                    } label: {
                        HStack {
                            // Avatar circle with first letter of name
                            Circle()
                                .fill(Color(hex: child.avatarColor ?? "#3b82f6"))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(child.name?.prefix(1) ?? "?"))
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .bold()
                                )
                            
                            VStack(alignment: .leading) {
                                Text(child.name ?? "Unknown")
                                    .font(.headline)
                                if child.age > 0 {
                                    Text("Age: \(child.age)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            // Show total balance
                            VStack(alignment: .trailing) {
                                Text("$\(child.spendingBalance + child.savingsBalance + child.givingBalance, specifier: "%.2f")")
                                    .font(.headline)
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Children")
            .toolbar {
                Button(action: {
                    showingAddChild = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildView()
            }
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
