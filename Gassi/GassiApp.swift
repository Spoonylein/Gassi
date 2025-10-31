//
//  GassiApp.swift
//  Gassi
//
//  Created by Jan Löffel on 09.08.22.
//

import SwiftUI
import SpoonFW

@main
struct GassiApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var persistenceController = CoreDataController.shared
    @StateObject private var settings: CDGassiSettings = CoreDataController.shared.settings
    @StateObject private var geoController = GeoController()
    
    private let actionService = ActionService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(settings)
                .environmentObject(actionService)
                .environmentObject(geoController)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                persistenceController.save()
            case .active:
                geoController.requestLocation()
            default:
                print(phase)
            }
        }
    }
}
