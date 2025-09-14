//
//  EchoApp.swift
//  Echo
//
//  Created by sid on 14/09/25.
//

import SwiftUI

@main
struct EchoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
