//
//  GassiApp.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI

@main
struct GassiApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var navigationController = NavigationController()

    let coreDataController = CoreDataController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataController.container.viewContext)
                .environmentObject(navigationController)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                coreDataController.save()
            default:
                print(phase)
            }
        }
    }
}
