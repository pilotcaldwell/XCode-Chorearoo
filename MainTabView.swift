import SwiftUI
import CoreData

struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        TabView {
            ChildrenListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Children")
                }
            
            ChoreLibraryView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Chores")
                }
            
            ParentStoreView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Store")
                }
            
            ParentApprovalsView()
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Approvals")
                }
            
            SettingsView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView(isAuthenticated: .constant(true))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
