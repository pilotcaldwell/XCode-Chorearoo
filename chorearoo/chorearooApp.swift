//
//  chorearooApp.swift
//  chorearoo
//
//  Created by Chase Caldwell on 10/8/25.
//

import SwiftUI
import CoreData

@main
struct chorearooApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
