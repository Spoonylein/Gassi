//
//  Persistence.swift
//  Gassi
//
//  Created by Jan Löffel on 19.07.23.
//

import CoreData

struct CoreDataController {
    // MARK: Statics
    /// The singleton object of this `CoreDataController`
    static let shared = CoreDataController()
    
    static func newDog(context: NSManagedObjectContext, name: String = "new dog", breed: GassiBreed? = nil, birthday: Date? = nil, sex: GassiSex? = nil, events: NSSet? = nil) -> GassiDog {
        let dog = GassiDog(context: context)

        dog.id = UUID()
        dog.name = name
        dog.breed = breed
        dog.birthday = birthday
        dog.sex = sex
        if let _events = events { dog.addToEvents(_events) }
        
        return dog
    }

    static func newBreed(context: NSManagedObjectContext, name: String = "new dog", dogs: NSSet? = nil) -> GassiBreed {
        let breed = GassiBreed(context: context)

        breed.id = UUID()
        breed.name = name
        if let _dogs = dogs { breed.addToDogs(_dogs) }
        
        return breed
    }

    static func newSex(context: NSManagedObjectContext, name: String = "new sex", dogs: NSSet? = nil) -> GassiSex {
        let sex = GassiSex(context: context)

        sex.id = UUID()
        sex.name = name
        if let _dogs = dogs { sex.addToDogs(_dogs) }
        
        return sex
    }

    static func newType(context: NSManagedObjectContext, name: String = "new type", predict: Bool = false, subtypes: NSSet? = nil, events: NSSet? = nil) -> GassiType {
        let type = GassiType(context: context)

        type.id = UUID()
        type.name = name
        type.predict = predict
        if let _subtypes = subtypes { type.addToSubtypes(_subtypes) }
        if let _events = events { type.addToEvents(_events) }
        
        return type
    }

    static func newSubtype(context: NSManagedObjectContext, name: String = "new subtype", types: NSSet? = nil, events: NSSet? = nil) -> GassiSubtype {
        let subtype = GassiSubtype(context: context)

        subtype.id = UUID()
        subtype.name = name
        if let _types = types {
            subtype.addToTypes(_types)
        }
        if let _events = events { subtype.addToEvents(_events) }

        return subtype
    }

    static func newEvent(context: NSManagedObjectContext, timestamp: Date = Date.now, dog: GassiDog, type: GassiType, subtype: GassiSubtype? = nil) -> GassiEvent {
        let event = GassiEvent(context: context)

        event.id = UUID()
        event.timestamp = timestamp
        event.dog = dog
        event.type = type
        event.subtype = subtype

        return event
    }

    static var preview: CoreDataController = {
        let result = CoreDataController(inMemory: true)
        let viewContext = result.container.viewContext

        let sex_female = newSex(context: viewContext, name: "female", dogs: nil)
        let sex_male = newSex(context: viewContext, name: "male", dogs: nil)
        let breed_whippet = newBreed(context: viewContext, name: "Whippet", dogs: nil)
        let dog_lejla = newDog(context: viewContext, name: "Lejla", breed: breed_whippet, birthday: nil, sex: sex_female, events: nil)
        let type_poo = newType(context: viewContext, name: "Poo", predict: true, subtypes: nil, events: nil)
        let subtype_hard = newSubtype(context: viewContext, name: "hard", types: [type_poo], events: nil)
        for index in 1...9 {
            let _ = newEvent(context: viewContext, timestamp: .now.addingTimeInterval(TimeInterval.random(in: 0...86400)), dog: dog_lejla, type: type_poo)
        }
        let _ = newEvent(context: viewContext, timestamp: .now.addingTimeInterval(TimeInterval.random(in: 0...86400)), dog: dog_lejla, type: type_poo, subtype: subtype_hard)

        return result
    }()
    
    // MARK: Properties
    /// The container encapsulating the core data stacK (i.e. the runtime database)
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Gassi")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
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
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // TODO: Check for DOG, SEX, TYPE, SUBTYPE and create default data if missing
        
    }
    
    // MARK: Load and save
    /// Saves the `viewContext` of the container if it has any changes.
    func save() {
        if container.viewContext.hasChanges {
            print("Saving changes of core data...")
            do {
                try container.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } else {
            print("No changes of core data to save.")
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
