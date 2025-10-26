import SwiftUI
import SwiftUI
import CoreData

struct AddChildView: View {
    // Access to Core Data
    @Environment(\.managedObjectContext) private var viewContext
    // Dismisses this screen when done
    @Environment(\.dismiss) private var dismiss
    
    // Form fields - these store what the user types
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var pin: String = ""
    @State private var avatarColor: Color = .blue
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient for the entire screen (KidTheme)
                AppThemeVibrant.mainGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section for Child Information with card style background
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Child Information")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                            
                            TextField("Name", text: $name)
                                .padding()
                                .background(AppThemeVibrant.purple.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                            
                            TextField("Age", text: $age)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(AppThemeVibrant.purple.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                            
                            TextField("PIN (4 digits)", text: $pin)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(AppThemeVibrant.purple.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(AppThemeVibrant.cardGradient) // Card style background
                        .cornerRadius(15)
                        .shadow(color: AppThemeVibrant.purple.opacity(0.4), radius: 5, x: 0, y: 3)
                        
                        // Section for Avatar Color with card style background
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Avatar Color")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                            
                            ColorPicker("Choose Color", selection: $avatarColor)
                                .padding()
                                .background(AppThemeVibrant.purple.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(AppThemeVibrant.cardGradient) // Card style background
                        .cornerRadius(15)
                        .shadow(color: AppThemeVibrant.purple.opacity(0.4), radius: 5, x: 0, y: 3)
                        
                        // Save button styled boldly and playfully with KidTheme colors
                        Button(action: {
                            saveChild()
                        }) {
                            Text("Save Child")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppThemeVibrant.purple)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .disabled(name.isEmpty || pin.isEmpty)
                        .opacity((name.isEmpty || pin.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Child")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            }
            .foregroundColor(AppThemeVibrant.purple))
        }
    }
    
    // This function saves the child to Core Data
    private func saveChild() {
        // Create a new Child object
        let newChild = Child(context: viewContext)
        newChild.id = UUID()
        newChild.name = name
        newChild.age = Int16(age) ?? 0
        newChild.pin = pin
        newChild.avatarColor = avatarColor.toHex()
        newChild.spendingBalance = 0.0
        newChild.savingsBalance = 0.0
        newChild.givingBalance = 0.0
        newChild.weeklyCap = 10.0  // Set default weekly cap
        newChild.createdAt = Date()
        
        // Save to the database
        do {
            try viewContext.save()
            dismiss() // Close this screen
        } catch {
            print("Error saving child: \(error)")
        }
    }
}

// Helper to convert Color to hex string
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        return String(format:"#%06x", rgb)
    }
}

#Preview {
    AddChildView()
}
