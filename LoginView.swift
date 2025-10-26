import SwiftUI
import CoreData

enum UserRole {
    case parent
    case child(Child)
}

enum LoginType {
    case parent
    case child(Child)
}

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Child.name, ascending: true)],
        animation: .default)
    private var children: FetchedResults<Child>
    
    @Binding var isAuthenticated: Bool
    @Binding var userRole: UserRole?
    
    @State private var loginType: LoginType?
    @State private var showError = false
    @State private var errorMessage = ""
    
    let parentPIN = "9999"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground) // System default background
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.purple) // KidTheme purple for icon pop
                        Text("Chorearoo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.orange) // changed to system orange for heading pop
                        Text("Chore Tracker")
                            .font(.subheadline)
                            .foregroundColor(.green) // changed to system green as subtitle color
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Who are you?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue) // changed to system blue for question text
                        
                        Button(action: {
                            loginType = .parent
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Parent")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.purple) // KidTheme purple for Parent button
                            .foregroundColor(.white)
                            .cornerRadius(20) // Larger, rounder corners
                            .font(.headline) // Larger font for playful look
                        }
                        
                        if !children.isEmpty {
                            ForEach(children) { child in
                                Button(action: {
                                    loginType = .child(child)
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(Color(hex: child.avatarColor ?? "#3b82f6"))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(String(child.name?.prefix(1) ?? "?"))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                            )
                                        Text(child.name ?? "Unknown")
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppTheme.textPrimary) // Use dark text for visibility
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemBackground)) // System card background for child cards
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(AppTheme.purple, lineWidth: 1.5) // Purple border for visibility
                                    )
                                    .cornerRadius(20) // Larger, rounder corners for cards
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $loginType) { type in
                PINSheetView2(
                    loginType: type,
                    parentPIN: parentPIN,
                    onSuccess: { role in
                        userRole = role
                        isAuthenticated = true
                        loginType = nil
                    },
                    onError: { msg in
                        errorMessage = msg
                        showError = true
                        loginType = nil
                    },
                    onCancel: {
                        loginType = nil
                    }
                )
            }
            .alert("Incorrect PIN", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

extension LoginType: Identifiable {
    var id: String {
        switch self {
        case .parent:
            return "parent"
        case .child(let child):
            return child.id?.uuidString ?? "unknown"
        }
    }
}

struct PINSheetView2: View {
    let loginType: LoginType
    let parentPIN: String
    let onSuccess: (UserRole) -> Void
    let onError: (String) -> Void
    let onCancel: () -> Void
    
    @State private var pin: String = ""
    
    var isParent: Bool {
        if case .parent = loginType {
            return true
        }
        return false
    }
    
    var child: Child? {
        if case .child(let child) = loginType {
            return child
        }
        return nil
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Cancel") {
                    onCancel()
                }
                .padding()
            }
            
            Spacer()
            
            PINEntryView(
                pin: $pin,
                title: isParent ? "Enter Parent PIN" : "Enter Your PIN"
            )
            
            Spacer()
            
            if pin.count == 4 {
                Button(action: {
                    checkPIN()
                }) {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue) // System blue for Submit button
                        .foregroundColor(.white)
                        .cornerRadius(20) // Larger, rounder corners for Submit
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    func checkPIN() {
        if isParent {
            if pin == parentPIN {
                onSuccess(.parent)
            } else {
                onError("Incorrect parent PIN")
            }
        } else {
            if let child = child, pin == child.pin {
                onSuccess(.child(child))
            } else {
                onError("Incorrect PIN")
            }
        }
    }
}



#Preview {
    LoginView(isAuthenticated: .constant(false), userRole: .constant(nil))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

