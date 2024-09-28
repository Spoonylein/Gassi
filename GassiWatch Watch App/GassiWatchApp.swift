//
//  GassiWatchApp.swift
//  GassiWatch Watch App
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI

@main
struct GassiWatchApp: App {
    let coreDataController = CoreDataController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataController.container.viewContext)
        }
    }
}
