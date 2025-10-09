import SwiftUI
import CoreData

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var userRole: UserRole?
    
    var body: some View {
        Group {
            if isAuthenticated {
                if let role = userRole {
                    switch role {
                    case .parent:
                        MainTabView(isAuthenticated: $isAuthenticated)
                    case .child(let child):
                        ChildDashboardView(
                            child: child,
                            isAuthenticated: $isAuthenticated,
                            userRole: $userRole
                        )
                    }
                }
            } else {
                LoginView(isAuthenticated: $isAuthenticated, userRole: $userRole)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
