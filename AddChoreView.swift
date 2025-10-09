import SwiftUI
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
            Form {
                Section(header: Text("Chore Details")) {
                    TextField("Chore Name (e.g., Make Bed)", text: $name)
                    
                    TextField("Description (optional)", text: $choreDescription)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section {
                    Button("Save Chore") {
                        saveChore()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
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
            dismiss()
        } catch {
            print("Error saving chore: \(error)")
        }
    }
}


#Preview {
    AddChoreView()
}
