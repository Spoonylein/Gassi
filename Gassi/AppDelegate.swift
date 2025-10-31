//
//  AppDelegate.swift
//  Gassi
//
//  Created by Jan Löffel on 19.06.22.
//

import UIKit
import Intents

class AppDelegate: NSObject, UIApplicationDelegate {
    private let actionService = ActionService.shared
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                                                                       
        if let shortcutItem = options.shortcutItem {
            actionService.action = Action(shortcutItem: shortcutItem)
        }
        
        let configuration = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)

        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    // TODO: Implementieren
    /// Handles intents when called through a shortcut
    /// - Parameters:
    ///   - application: The application that called the shortcut
    ///   - intent: The intent handling the shortcut
    /// - Returns: A description
/*    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        switch intent {
        case is AddPeeIntent:
            let _ = CoreDataController.shared.newGassiEvent(timeStamp: .now, type: GassiEventType.pee.rawValue)
            return AddPeeIntentHandler()
        case is AddPooIntent:
            let _ = CoreDataController.shared.newGassiEvent(timeStamp: .now, type: GassiEventType.poo.rawValue)
            return AddPooIntentHandler()
        default:
            return nil
        }
    } */
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    private let actionService = ActionService.shared
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        actionService.action = Action(shortcutItem: shortcutItem)
        completionHandler(true)
    }
}
