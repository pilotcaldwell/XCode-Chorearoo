import SwiftUI
import CoreData

struct CompleteChoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let child: Child
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chore.name, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default)
    private var chores: FetchedResults<Chore>
    
    @FetchRequest private var pendingCompletions: FetchedResults<ChoreCompletion>
    
    @State private var selectedChore: Chore?
    @State private var showCapReachedAlert = false
    
    init(child: Child) {
        self.child = child
        
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
    
    var body: some View {
        ZStack { // Add background gradient for whole screen - playful theme background
            KidTheme.mainGradient
                .ignoresSafeArea()
            
            NavigationView {
                VStack {
                    if chores.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "list.clipboard")
                                .font(.system(size: 60))
                                .foregroundColor(KidTheme.purple) // Using theme purple for icon
                            Text("No chores available")
                                .font(.headline)
                                .foregroundColor(KidTheme.purple) // Themed text color
                            Text("Ask a parent to add chores to the library")
                                .font(.subheadline)
                                .foregroundColor(KidTheme.purple.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(KidTheme.cardGradient) // Card gradient on no chores view - friendly card look
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill") // playful icon near earnings
                                    .foregroundColor(KidTheme.green)
                                Text("This week: $\(thisWeekEarnings, specifier: "%.2f") of $\(child.weeklyCap, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(KidTheme.purple) // Themed text for earnings
                            }
                            .padding(.horizontal)
                            
                            ProgressView(value: thisWeekEarnings, total: child.weeklyCap)
                                .accentColor(KidTheme.orange) // Themed progress bar color
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        .padding()
                        .background(KidTheme.cardGradient) // Card gradient behind progress and earnings - friendly card look
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        List(chores) { chore in
                            Button(action: {
                                handleChoreSelection(chore)
                            }) {
                                HStack {
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
                                    
                                    Text("$\(chore.amount, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(wouldExceedCap(chore) ? KidTheme.orange : KidTheme.green) // Use theme colors for amounts
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                            .disabled(wouldExceedCap(chore))
                            .opacity(wouldExceedCap(chore) ? 0.5 : 1.0)
                            .listRowBackground(
                                KidTheme.cardGradient // Use card gradient behind each list row - playful cards for chores
                                    .cornerRadius(10)
                                    .padding(.vertical, 4)
                            )
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                    }
                }
                .navigationTitle("Complete Chore")
                .navigationBarItems(trailing:
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(KidTheme.purple) // Themed button background purple
                    .foregroundColor(.white) // White text on purple
                    .cornerRadius(25)
                ) // Large rounded cancel button with theme colors
                
                .alert("Complete Chore?", isPresented: Binding(
                    get: { selectedChore != nil },
                    set: { if !$0 { selectedChore = nil } }
                )) {
                    Button("Cancel", role: .cancel) {
                        selectedChore = nil
                    }
                    Button("Complete") {
                        if let chore = selectedChore {
                            completeChore(chore)
                        }
                    }
                    .tint(KidTheme.green) // Green tinted complete button for success
                } message: {
                    if let chore = selectedChore {
                        Text("Mark \"\(chore.name ?? "")\" as complete for $\(chore.amount, specifier: "%.2f")?")
                    }
                }
                .alert("Weekly Cap Reached", isPresented: $showCapReachedAlert) {
                    Button("OK", role: .cancel) {}
                        .tint(KidTheme.orange) // Orange button for alert confirmation
                } message: {
                    Text("You've reached your weekly earning cap of $\(child.weeklyCap, specifier: "%.2f"). Ask a parent for a bonus or wait until next week!")
                }
            }
        }
    }
    
    private func wouldExceedCap(_ chore: Chore) -> Bool {
        return (thisWeekEarnings + chore.amount) > child.weeklyCap
    }
    
    private func handleChoreSelection(_ chore: Chore) {
        if wouldExceedCap(chore) {
            showCapReachedAlert = true
        } else {
            selectedChore = chore
        }
    }
    
    private func completeChore(_ chore: Chore) {
        let completion = ChoreCompletion(context: viewContext)
        completion.id = UUID()
        completion.status = "pending"
        completion.completedAt = Date()
        completion.weekStartDate = Self.getStartOfWeek()
        completion.isBonus = false
        
        let total = chore.amount
        completion.spendingAmount = total * 0.8
        completion.savingsAmount = total * 0.1
        completion.givingAmount = total * 0.1
        
        completion.child = child
        completion.chore = chore
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error completing chore: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let child = Child(context: context)
    child.name = "Sample Child"
    child.weeklyCap = 10.0
    
    return CompleteChoreView(child: child)
        .environment(\.managedObjectContext, context)
}

