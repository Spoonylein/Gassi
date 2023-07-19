//
//  GassiApp.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI

@main
struct GassiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
