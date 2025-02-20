//
//  HitcraftApp.swift
//  Hitcraft
//
//  Created by Oudi Antebi on 20/02/2025.
//

import SwiftUI

@main
struct HitcraftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
