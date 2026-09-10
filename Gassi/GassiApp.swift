//
//  GassiApp.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import SwiftUI
import UIKit

private enum AppShortcutAction: String, CaseIterable {
    case addPee = "de.loeffeljan.gassi.addPee"
    case addPoo = "de.loeffeljan.gassi.addPoo"

    init?(shortcutItem: UIApplicationShortcutItem) {
        self.init(rawValue: shortcutItem.type)
    }

    var shortcutItem: UIApplicationShortcutItem {
        switch self {
        case .addPee:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: localizedString("ShortcutAddPeeTitle", standardString: GassiType.pee.nameString),
                localizedSubtitle: localizedString("ShortcutAddPeeSubtitle", standardString: "Pipi-Ereignis hinzufügen"),
                icon: UIApplicationShortcutIcon(systemImageName: "drop.fill")
            )
        case .addPoo:
            return UIApplicationShortcutItem(
                type: rawValue,
                localizedTitle: localizedString("ShortcutAddPooTitle", standardString: GassiType.poo.nameString),
                localizedSubtitle: localizedString("ShortcutAddPooSubtitle", standardString: "Kot-Ereignis hinzufügen"),
                icon: UIApplicationShortcutIcon(systemImageName: "pawprint.fill")
            )
        }
    }

    @MainActor
    func perform(with coreDataController: CoreDataController) -> Bool {
        let viewContext = coreDataController.container.viewContext
        let type: GassiType

        switch self {
        case .addPee:
            type = GassiType.pee
        case .addPoo:
            type = GassiType.poo
        }

        _ = GassiEvent.new(context: viewContext, dog: GassiDog.current, type: type)
        coreDataController.save()
        return true
    }
}

@MainActor
private final class AppShortcutController {
    static let shared = AppShortcutController()

    private var coreDataController: CoreDataController?
    private var pendingAction: AppShortcutAction?

    func configure(coreDataController: CoreDataController) {
        self.coreDataController = coreDataController
        UIApplication.shared.shortcutItems = AppShortcutAction.allCases.map(\.shortcutItem)
        _ = performPendingActionIfPossible()
    }

    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = AppShortcutAction(shortcutItem: shortcutItem) else {
            return false
        }

        pendingAction = action
        return performPendingActionIfPossible()
    }

    @discardableResult
    private func performPendingActionIfPossible() -> Bool {
        guard let pendingAction, let coreDataController else {
            return false
        }

        let handled = pendingAction.perform(with: coreDataController)
        if handled {
            self.pendingAction = nil
        }

        return handled
    }
}

private final class GassiAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = GassiSceneDelegate.self
        return configuration
    }
}

private final class GassiSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            Task { @MainActor in
                _ = AppShortcutController.shared.handle(shortcutItem: shortcutItem)
            }
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let handled = AppShortcutController.shared.handle(shortcutItem: shortcutItem)
            completionHandler(handled)
        }
    }
}

@main
struct GassiApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var navigationController = NavigationController()
    @UIApplicationDelegateAdaptor(GassiAppDelegate.self) private var appDelegate

    let coreDataController = CoreDataController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataController.container.viewContext)
                .environmentObject(navigationController)
                .task {
                    AppShortcutController.shared.configure(coreDataController: coreDataController)
                }
        }
        .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
            switch newScenePhase {
            case .background:
                    coreDataController.save()
            default:
                    print(newScenePhase)
            }
        }
    }
}
