import SwiftUI

struct SettingsView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        isAuthenticated = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.circle.fill")
                                .foregroundColor(.red)
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(isAuthenticated: .constant(true))
}
