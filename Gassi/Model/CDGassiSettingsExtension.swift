//
//  CDGassiSettingsExtension.swift
//  Gassi
//
//  Created by Jan Löffel on 15.08.22.
//

import CoreData

extension CDGassiSettings {
    
    static func new(viewContext: NSManagedObjectContext, gracePeriod: Double = 900, groomingDays: Int16 = 90, currentDog: CDGassiDog? = nil, favoriteCategory1: CDGassiCategory? = nil, favoriteCategory2: CDGassiCategory? = nil) -> CDGassiSettings {
        let newItem = CDGassiSettings(context: viewContext)
        
        newItem.cd_id = UUID()
        newItem.cd_gracePeriod = gracePeriod
        newItem.cd_groomingDays = groomingDays
        
        newItem.cd_currentDog = currentDog
        newItem.cd_favoriteCategory1 = favoriteCategory1
        newItem.cd_favoriteCategory2 = favoriteCategory2
        
        return newItem
    }
    
    func addFavorite(_ category: CDGassiCategory?) {
        if [favoriteCategory1, favoriteCategory2].contains(category) { return }

        if favoriteCategory1 == nil { favoriteCategory1 = category; return }
        if favoriteCategory2 == nil { favoriteCategory2 = category; return }
        
        favoriteCategory2 = favoriteCategory1
        favoriteCategory1 = category
    }

    func removeFavorite(_ category: CDGassiCategory?) {
        if favoriteCategory1 == category { favoriteCategory1 = nil }
        if favoriteCategory2 == category { favoriteCategory2 = nil }
    }
}
