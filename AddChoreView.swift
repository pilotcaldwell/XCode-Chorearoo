import SwiftUI
import UIKit
import CoreData

struct AddChoreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Form fields
    @State private var name: String = ""
    @State private var choreDescription: String = ""
    @State private var amount: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground) // System default background
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Chore Details")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            TextField("Chore Name (e.g., Make Bed)", text: $name)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Description (optional)", text: $choreDescription)
                                .textFieldStyle(.roundedBorder)
                            
                            HStack {
                                Text("$")
                                TextField("Amount", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground)) // System card background
                        .cornerRadius(12)
                        
                        Button("Save Chore") {
                            saveChore()
                        }
                        .disabled(name.isEmpty || amount.isEmpty)
                        .padding()
                        .background(AppTheme.purple) // Bold purple background for prominent Save button
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Chore")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func saveChore() {
        let newChore = Chore(context: viewContext)
        newChore.id = UUID()
        newChore.name = name
        newChore.choreDescription = choreDescription.isEmpty ? nil : choreDescription
        newChore.amount = Double(amount) ?? 0.0
        newChore.isActive = true
        newChore.createdAt = Date()
        
        do {
            try viewContext.save()
            // Trigger gentle haptic feedback on successful save
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            dismiss()
        } catch {
            print("Error saving chore: \(error)")
        }
    }
}


#Preview {
    AddChoreView()
}

