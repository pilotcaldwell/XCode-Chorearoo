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
        NavigationView {
            VStack(spacing: 0) {
                // Progress Card at Top
                if !chores.isEmpty {
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Text("🎯")
                                .font(.title)
                            Text("Weekly Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppThemeVibrant.textPrimary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("$\(thisWeekEarnings, specifier: "%.2f") of $\(child.weeklyCap, specifier: "%.2f")")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppThemeVibrant.green)
                            
                            ProgressView(value: thisWeekEarnings, total: child.weeklyCap)
                                .progressViewStyle(LinearProgressViewStyle(tint: AppThemeVibrant.green))
                                .scaleEffect(1.2)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                if chores.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Text("📝")
                            .font(.system(size: 80))
                        Text("No Chores Available")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppThemeVibrant.textPrimary)
                        Text("Ask a parent to add some chores for you to complete!")
                            .font(.body)
                            .foregroundColor(AppThemeVibrant.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Chores List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chores) { chore in
                                Button(action: {
                                    handleChoreSelection(chore)
                                }) {
                                    HStack(spacing: 16) {
                                        // Chore Icon
                                        Circle()
                                            .fill(AppThemeVibrant.blue.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text("✨")
                                                    .font(.title2)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(chore.name ?? "Unknown Chore")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(AppThemeVibrant.textPrimary)
                                                .multilineTextAlignment(.leading)
                                            
                                            if let description = chore.choreDescription, !description.isEmpty {
                                                Text(description)
                                                    .font(.subheadline)
                                                    .foregroundColor(AppThemeVibrant.textSecondary)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("$\(chore.amount, specifier: "%.2f")")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(wouldExceedCap(chore) ? AppThemeVibrant.orange : AppThemeVibrant.green)
                                            
                                            if wouldExceedCap(chore) {
                                                Text("Cap Reached")
                                                    .font(.caption)
                                                    .foregroundColor(AppThemeVibrant.orange)
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                wouldExceedCap(chore) ?
                                                AppThemeVibrant.orange.opacity(0.3) :
                                                AppThemeVibrant.blue.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )
                                    .scaleEffect(wouldExceedCap(chore) ? 0.95 : 1.0)
                                    .opacity(wouldExceedCap(chore) ? 0.7 : 1.0)
                                }
                                .disabled(wouldExceedCap(chore))
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Complete Chores 🎯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(AppThemeVibrant.textOnColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppThemeVibrant.purple)
                    .cornerRadius(20)
                }
            }
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
                .tint(AppThemeVibrant.green) // Green tinted complete button for success
            } message: {
                if let chore = selectedChore {
                    Text("Mark \"\(chore.name ?? "")\" as complete for $\(chore.amount, specifier: "%.2f")?")
                }
            }
            .alert("Weekly Cap Reached", isPresented: $showCapReachedAlert) {
                Button("OK", role: .cancel) {}
                    .tint(AppThemeVibrant.orange) // Orange button for alert confirmation
            } message: {
                Text("You've reached your weekly earning cap of $\(child.weeklyCap, specifier: "%.2f"). Ask a parent for a bonus or wait until next week!")
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

