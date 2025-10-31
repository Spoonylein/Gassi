//
//  CoreDataController.swift
//  Gassi
//
//  Created by Jan Löffel on 09.08.22.
//

import CoreData
import SwiftUI

class CoreDataController: ObservableObject {
    // MARK: Statics
    // Singleton pattern
    /// The singleton object of a `CoreDataController`, i.e. the currently used instance.
    static let shared = CoreDataController()
    
    // Preview
    /// The `Preview` object of a `CoreDataController`
    static var preview: CoreDataController = {
        print("Preview")
        let result = CoreDataController(inMemory: true)
        let viewContext = result.container.viewContext

        let gassiCategory1 = result.settings.favoriteCategory1
        let gassiCategory2 = result.settings.favoriteCategory2
        for _ in 1..<750 {
            let _ = CDGassiEvent.new(viewContext: result.container.viewContext,timestamp: Date.now.addingTimeInterval(-Double.random(in: 0...3500000)), category: gassiCategory1, gracePeriod: 0)
        }
        for _ in 1..<250 {
            let _ = CDGassiEvent.new(viewContext: result.container.viewContext,timestamp: Date.now.addingTimeInterval(-Double.random(in: 0...3500000)), category: gassiCategory2, gracePeriod: 0)
        }

        return result
    }()
    
    // MARK: Properties
    /// The container encapsulating the core data stack (i.e. the runtime database).
    let container = NSPersistentContainer(name: "Gassi")

    var settings: CDGassiSettings = CDGassiSettings()
        
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        })

        // Check for the 1st fetched CDGassiSetting and save it in `settings` otherwise create new settings
        if let fetchedGassiSettings = try? container.viewContext.fetch(CDGassiSettings.fetchRequest()) {
            if fetchedGassiSettings.isEmpty {
                settings = CDGassiSettings.new(viewContext: container.viewContext)
            } else {
                settings = fetchedGassiSettings.first ?? CDGassiSettings.new(viewContext: container.viewContext)
            }
        } else {
            settings = CDGassiSettings.new(viewContext: container.viewContext)
        }
        
        // Check for categories and create stadard categories if empty
        if let allGassiCategorys = try? container.viewContext.fetch(CDGassiCategory.fetchRequest()) {
            if allGassiCategorys.isEmpty {
                // TODO: Ask for creation of default categories
                // Anlegen der Standardkategorien
                let training: CDGassiCategory = CDGassiCategory.new(viewContext: container.viewContext, name: NSLocalizedString("training", comment: ""), sign: NSLocalizedString("trainingSign", comment: ""))
                let treat: CDGassiCategory = CDGassiCategory.new(viewContext: container.viewContext, name: NSLocalizedString("treat", comment: ""), sign: NSLocalizedString("treatSign", comment: ""))
                let vomit: CDGassiCategory = CDGassiCategory.new(viewContext: container.viewContext, name: NSLocalizedString("vomit", comment: ""), sign: NSLocalizedString("vomitSign", comment: ""))
                let diarrhea: CDGassiCategory = CDGassiCategory.new(viewContext: container.viewContext, name: NSLocalizedString("diarrhea", comment: ""), sign: NSLocalizedString("diarrheaSign", comment: ""))
                let pee = CDGassiCategory.new(viewContext: container.viewContext, name: NSLocalizedString("pee", comment: ""), sign: NSLocalizedString("peeSign", comment: ""), isDefault: true)
                let poo: CDGassiCategory = CDGassiCategory.new(viewContext: container.viewContext, name: NSLocalizedString("poo", comment: ""), sign: NSLocalizedString("pooSign", comment: ""), isDefault: true)
                
                settings.favoriteCategory1 = poo
                settings.favoriteCategory2 = pee
            }
        }

    }

    // MARK: Load and save
    /// Saves the `viewContext` of the container if it has any changes.
    func save() {
        print("Saving...")
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    /// Clears all Core Data
    private func clearCoreData() {
        guard let url = container.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = container.persistentStoreCoordinator
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("Attempted to clear persistent store: " + error.localizedDescription)
        }
    }

}

