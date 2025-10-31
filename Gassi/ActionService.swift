//
//  ActionService.swift
//  Gassi
//
//  Created by Jan Löffel on 19.06.22.
//

import UIKit


/// enum for the `ActionsType`of pee or poo.
enum ActionType: String {
    case pee = "pee"
    case poo = "poo"
}

/// enum for `Action` of type pee or poo.
enum Action: Equatable {
    case pee
    case poo
    
    
    /// Initialize of `Action` that will return the `ActionType` of the given `UIApplicationShortcutItem`
    /// - Parameter shortcutItem: The passed shortcut item as `UIApplicationShortcutItem`.
    init?(shortcutItem: UIApplicationShortcutItem) {
        guard let type = ActionType(rawValue: shortcutItem.type) else {
            return nil
        }
        
        switch type {
        case .pee:
            self = .pee
        case .poo:
            self = .poo
        }
    }
}

/// Class for `ActionService`
class ActionService: ObservableObject {
    /// Singleton accessor
    static let shared = ActionService()
    
    /// Published Property representing the action
    @Published var action: Action?
}
