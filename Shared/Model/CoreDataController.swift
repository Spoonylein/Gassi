//
//  CoreDataController.swift
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
        if !inMemory, let currentDog = initCurrentDog() {
            currentDog.makeCurrent()
        } else {
            print("No dog fetched, creating default one.")
            GassiDog.current = GassiDog.newDefault(context: container.viewContext)
        }
        
        initBreeds()
        
        if !inMemory, let femaleSex: GassiSex = initGassi(entityName: "GassiSex", defaultIDString: GassiIDStrings.femaleSex.rawValue) {
            GassiSex.female = femaleSex
        } else {
            print("No female sex fetched, creating default one.")
            GassiSex.female = GassiSex.newFemale(context: container.viewContext)
        }
        
        if !inMemory, let maleSex: GassiSex = initGassi(entityName: "GassiSex", defaultIDString: GassiIDStrings.maleSex.rawValue) {
            GassiSex.male = maleSex
        } else {
            print("No male sex fetched, creating default one.")
            GassiSex.male = GassiSex.newMale(context: container.viewContext)
        }
        
        if !inMemory, let peeType: GassiType = initGassi(entityName: "GassiType", defaultIDString: GassiIDStrings.peeType.rawValue) {
            GassiType.pee = peeType
        } else {
            print("No pee type fetched, creating default one.")
            GassiType.pee = GassiType.newPee(context: container.viewContext)
        }
        
        if !inMemory, let pooType: GassiType = initGassi(entityName: "GassiType", defaultIDString: GassiIDStrings.pooType.rawValue) {
            GassiType.poo = pooType
        } else {
            print("No poo type fetched, creating default one.")
            GassiType.poo = GassiType.newPoo(context: container.viewContext)
        }
        
        if !inMemory, let hardPooSubtype: GassiSubtype = initGassi(entityName: "GassiSubtype", defaultIDString: GassiIDStrings.hardPooSubtype.rawValue) {
            GassiSubtype.hardPoo = hardPooSubtype
        } else {
            print("No hard poo subtype fetched, creating default one.")
            GassiSubtype.hardPoo = GassiSubtype.newHardPoo(context: container.viewContext)
        }
        
        if !inMemory, let softPooSubtype: GassiSubtype = initGassi(entityName: "GassiSubtype", defaultIDString: GassiIDStrings.softPooSubtype.rawValue) {
            GassiSubtype.softPoo = softPooSubtype
        } else {
            print("No soft poo subtype fetched, creating default one.")
            GassiSubtype.softPoo = GassiSubtype.newSoftPoo(context: container.viewContext)
        }
        
        if !inMemory, let diarrheaPooSubtype: GassiSubtype = initGassi(entityName: "GassiSubtype", defaultIDString: GassiIDStrings.diarrheaPooSubtype.rawValue) {
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
    
    private func initBreeds() {
        if let breeds = try? container.viewContext.fetch(GassiBreed.fetchRequest()) {
            if breeds.isEmpty {
                print("No breeds fetched, creating default ones.")
                let _ = GassiBreed.new(context: container.viewContext, name: "Mischling")
                let _ = GassiBreed.new(context: container.viewContext, name: "Afghanischer Windhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Airedale-Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Akita Inu")
                let _ = GassiBreed.new(context: container.viewContext, name: "Malamute")
                let _ = GassiBreed.new(context: container.viewContext, name: "Appenzeller Sennenhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Australian Shepherd")
                let _ = GassiBreed.new(context: container.viewContext, name: "Azawakh")
                let _ = GassiBreed.new(context: container.viewContext, name: "Barsoi")
                let _ = GassiBreed.new(context: container.viewContext, name: "Basenji")
                let _ = GassiBreed.new(context: container.viewContext, name: "Basset Hound")
                let _ = GassiBreed.new(context: container.viewContext, name: "Beagle")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bearded Collie")
                let _ = GassiBreed.new(context: container.viewContext, name: "Berner Sennenhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bernhardiner")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bichon Frisé")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bobtail")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bologneser")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bolonka Zwetna")
                let _ = GassiBreed.new(context: container.viewContext, name: "Border Collie")
                let _ = GassiBreed.new(context: container.viewContext, name: "Boxer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bracke")
                let _ = GassiBreed.new(context: container.viewContext, name: "Briard")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bulldogge")
                let _ = GassiBreed.new(context: container.viewContext, name: "Bullterrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Cairn-Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Cane Corso")
                let _ = GassiBreed.new(context: container.viewContext, name: "Cavalier King Charles Spaniel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Chihuahua")
                let _ = GassiBreed.new(context: container.viewContext, name: "Chinesischer Schopfhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Chow-Chow")
                let _ = GassiBreed.new(context: container.viewContext, name: "Cockerpoo")
                let _ = GassiBreed.new(context: container.viewContext, name: "Cockerspaniel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Collie")
                let _ = GassiBreed.new(context: container.viewContext, name: "Dackel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Dalmatiner")
                let _ = GassiBreed.new(context: container.viewContext, name: "Deerhound")
                let _ = GassiBreed.new(context: container.viewContext, name: "Deutsche Dogge")
                let _ = GassiBreed.new(context: container.viewContext, name: "Deutscher Schäferhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Dobermann")
                let _ = GassiBreed.new(context: container.viewContext, name: "Entlebucher Sennenhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Eurasier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Foxterrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Französische Bulldogge")
                let _ = GassiBreed.new(context: container.viewContext, name: "Galgo Espanol")
                let _ = GassiBreed.new(context: container.viewContext, name: "Golden Retriever")
                let _ = GassiBreed.new(context: container.viewContext, name: "Greyhound")
                let _ = GassiBreed.new(context: container.viewContext, name: "Grosser Münsterländer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Grosser Schweizer Sennenhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Havaneser")
                let _ = GassiBreed.new(context: container.viewContext, name: "Hovawart")
                let _ = GassiBreed.new(context: container.viewContext, name: "Husky")
                let _ = GassiBreed.new(context: container.viewContext, name: "Irischer Wolfshund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Irish Setter")
                let _ = GassiBreed.new(context: container.viewContext, name: "Italienisches Windspiel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Jack-Russell-Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Kangal")
                let _ = GassiBreed.new(context: container.viewContext, name: "King Charles Spaniel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Kooikerhondje")
                let _ = GassiBreed.new(context: container.viewContext, name: "Kromfohrländer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Labradoodle")
                let _ = GassiBreed.new(context: container.viewContext, name: "Labrador Retriever")
                let _ = GassiBreed.new(context: container.viewContext, name: "Lagotto Romagnolo")
                let _ = GassiBreed.new(context: container.viewContext, name: "Leonberger")
                let _ = GassiBreed.new(context: container.viewContext, name: "Lhasa Apso")
                let _ = GassiBreed.new(context: container.viewContext, name: "Löwchen")
                let _ = GassiBreed.new(context: container.viewContext, name: "Malinois")
                let _ = GassiBreed.new(context: container.viewContext, name: "Malteser")
                let _ = GassiBreed.new(context: container.viewContext, name: "Mastiff")
                let _ = GassiBreed.new(context: container.viewContext, name: "Mops")
                let _ = GassiBreed.new(context: container.viewContext, name: "Neufundländer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Papillon")
                let _ = GassiBreed.new(context: container.viewContext, name: "Parson-Russell-Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pekingese")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pharaonenhund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pinscher")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pitbull")
                let _ = GassiBreed.new(context: container.viewContext, name: "Podenco Canario")
                let _ = GassiBreed.new(context: container.viewContext, name: "Podengo Portugueso")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pudel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pudelpointer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Pyrenäenberghund")
                let _ = GassiBreed.new(context: container.viewContext, name: "Rauhhaardackel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Rhodesian Ridgeback")
                let _ = GassiBreed.new(context: container.viewContext, name: "Riesenschnauzer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Rottweiler")
                let _ = GassiBreed.new(context: container.viewContext, name: "Saluki")
                let _ = GassiBreed.new(context: container.viewContext, name: "Samojede")
                let _ = GassiBreed.new(context: container.viewContext, name: "Schipperke")
                let _ = GassiBreed.new(context: container.viewContext, name: "Schnauzer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Scottish Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Shar Pei")
                let _ = GassiBreed.new(context: container.viewContext, name: "Sheltie")
                let _ = GassiBreed.new(context: container.viewContext, name: "Shiba Inu")
                let _ = GassiBreed.new(context: container.viewContext, name: "Shih Tzu")
                let _ = GassiBreed.new(context: container.viewContext, name: "Sloughi")
                let _ = GassiBreed.new(context: container.viewContext, name: "Spitz")
                let _ = GassiBreed.new(context: container.viewContext, name: "Toy-Pudel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Weimaraner")
                let _ = GassiBreed.new(context: container.viewContext, name: "Welsh Corgi")
                let _ = GassiBreed.new(context: container.viewContext, name: "West Highland White Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Whippet")
                let _ = GassiBreed.new(context: container.viewContext, name: "Yorkshire Terrier")
                let _ = GassiBreed.new(context: container.viewContext, name: "Zwergpinscher")
                let _ = GassiBreed.new(context: container.viewContext, name: "Zwergpudel")
                let _ = GassiBreed.new(context: container.viewContext, name: "Zwergschnauzer")
                let _ = GassiBreed.new(context: container.viewContext, name: "Zwergspitz")
            }
        }
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
    
    private func initGassi<T: NSManagedObject>(entityName: String, defaultIDString: String = "") -> T? {
        var result: T? = nil
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", defaultIDString)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        if let items = try? container.viewContext.fetch(fetchRequest) {
            if !items.isEmpty {
                print("Fetched \(items.count) \(T.description()) using \(items.first! as T).")
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
