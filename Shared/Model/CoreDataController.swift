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
    
    static var preview: CoreDataController = {
        let result = CoreDataController(inMemory: true)
        let viewContext = result.container.viewContext

        // TODO: Move to `init`
//        let sex_male = newSex(context: viewContext, name: "male", dogs: nil)
//        let breed_whippet = newBreed(context: viewContext, name: "Whippet", dogs: nil)
//        let type_poo = newType(context: viewContext, name: "Poo", predict: true, subtypes: nil, events: nil)
//        let subtype_hard = newSubtype(context: viewContext, name: "hard", types: [type_poo], events: nil)
//        for index in 1...9 {
//            let _ = newEvent(context: viewContext, timestamp: .now.addingTimeInterval(TimeInterval.random(in: 0...86400)), dog: result.currentDog, type: type_poo)
//        }
//        let _ = newEvent(context: viewContext, timestamp: .now.addingTimeInterval(TimeInterval.random(in: 0...86400)), dog: result.currentDog, type: type_poo, subtype: subtype_hard)

        return result
    }()
    
    // MARK: Properties
    /// The container encapsulating the core data stacK (i.e. the runtime database)
    let container: NSPersistentCloudKitContainer
    var currentDog: GassiDog = GassiDog() {
        didSet {
            UserDefaults.standard.set(currentDog.id?.uuidString, forKey: UserDefaultsKeys.currentDogIDString.rawValue)
            print("currentDogID \(currentDog.id?.uuidString ?? "nil") saved in UserDefaults.")
        }
    }

    // MARK: Create and Read
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
        print("Core data store loaded. Checking for default data..")
        if let currentDog = initCurrentDog() {
            GassiDog.current = currentDog
        } else {
            print("No dog fetched, creating default one.")
            GassiDog.current = GassiDog.newDefault(context: container.viewContext)
        }
        
        if let femaleSex: GassiSex = initGassi(defaultIDString: GassiIDStrings.femaleSex.rawValue) {
            GassiSex.female = femaleSex
        } else {
            print("No female sex fetched, creating default one.")
            GassiSex.female = GassiSex.newFemale(context: container.viewContext)
        }

        if let maleSex: GassiSex = initGassi(defaultIDString: GassiIDStrings.maleSex.rawValue) {
            GassiSex.male = maleSex
        } else {
            print("No male sex fetched, creating default one.")
            GassiSex.female = GassiSex.newFemale(context: container.viewContext)
        }

        if let peeType: GassiType = initGassi(defaultIDString: GassiIDStrings.peeType.rawValue) {
            GassiType.pee = peeType
        } else {
            print("No pee type fetched, creating default one.")
            GassiType.pee = GassiType.newPee(context: container.viewContext)
        }

        if let pooType: GassiType = initGassi(defaultIDString: GassiIDStrings.pooType.rawValue) {
            GassiType.poo = pooType
        } else {
            print("No poo type fetched, creating default one.")
            GassiType.poo = GassiType.newPoo(context: container.viewContext)
        }

        if let hardPooSubtype: GassiSubtype = initGassi(defaultIDString: GassiIDStrings.hardPooSubtype.rawValue) {
            GassiSubtype.hardPoo = hardPooSubtype
        } else {
            print("No hard poo subtype fetched, creating default one.")
            GassiSubtype.hardPoo = GassiSubtype.newHardPoo(context: container.viewContext)
        }

        if let softPooSubtype: GassiSubtype = initGassi(defaultIDString: GassiIDStrings.softPooSubtype.rawValue) {
            GassiSubtype.softPoo = softPooSubtype
        } else {
            print("No soft poo subtype fetched, creating default one.")
            GassiSubtype.softPoo = GassiSubtype.newSoftPoo(context: container.viewContext)
        }

        if let diarrheaPooSubtype: GassiSubtype = initGassi(defaultIDString: GassiIDStrings.diarrheaPooSubtype.rawValue) {
            GassiSubtype.diarrheaPoo = diarrheaPooSubtype
        } else {
            print("No diarrhea poo subtype fetched, creating default one.")
            GassiSubtype.diarrheaPoo = GassiSubtype.newDiarrheaPoo(context: container.viewContext)
        }

    }
    
    private func initCurrentDog() -> GassiDog? {
        var result: GassiDog? = nil
        
        if let dogs = try? container.viewContext.fetch(GassiDog.fetchRequest()) {
            if !dogs.isEmpty {
                print("Fetched \(dogs.count) dogs.")
                if let currentDogIDString = UserDefaults.standard.string(forKey: UserDefaultsKeys.currentDogIDString.rawValue) {
                    result = dogs.first!
                    for dog in dogs {
                        if dog.id?.uuidString == currentDogIDString {
                            result = dog
                        }
                    }
                } else {
                    print("No currentDogID in UserDefaults, using 1st one from core data")
                    if let firstDog = dogs.first {
                        result = firstDog
                    } else {
                        fatalError("1st dog fetched from core data not usable.")
                    }
                }
            }
        }
        
        return result
    }
    
//    private func initFemaleSex() -> GassiSex? {
//        var result: GassiSex? = nil
//
//        if let sexes = try? container.viewContext.fetch(GassiSex.fetchRequest()) {
//            if !sexes.isEmpty {
//                print("Fetched \(sexes.count) sexes.")
//                for sex in sexes {
//                    if sex.id?.uuidString == GassiIDStrings.femaleSex.rawValue {
//                        result = sex
//                    }
//                }
//            }
//        }
//
//        if result == nil {
//            print("No female sex fetched, creating one...")
//            result = GassiSex.newFemale(context: container.viewContext)
//        }
//
//        return result
//    }
//
//    private func initMaleSex() -> GassiSex? {
//        var result: GassiSex? = nil
//
//        if let sexes = try? container.viewContext.fetch(GassiSex.fetchRequest()) {
//            if !sexes.isEmpty {
//                print("Fetched \(sexes.count) sexes.")
//                for sex in sexes {
//                    if sex.id?.uuidString == GassiIDStrings.maleSex.rawValue {
//                        result = sex
//                    }
//                }
//            }
//        }
//
//        if result == nil {
//            print("No male sex fetched, creating one...")
//            result = GassiSex.newMale(context: container.viewContext)
//        }
//
//        return result
//    }
    
    private func initGassi<T: NSManagedObject>(defaultIDString: String = "") -> T? {
        var result: T? = nil
        let fetchRequest = NSFetchRequest<T>()
        fetchRequest.predicate = NSPredicate(format: "id = %@", defaultIDString)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        if let items = try? container.viewContext.fetch(T.fetchRequest()) as? [T] {
            if !items.isEmpty {
                print("Fetched \(items.count) \(T.description()) using \(items.first!).")
                result = items.first!
            }
        }
        
        return result
    }

    // MARK: Update
    /// Saves the `viewContext` of the container if it has any changes.
    func save() {
        if container.viewContext.hasChanges {
            print("Saving changes of core data.")
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
    
    // MARK: Delete
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
