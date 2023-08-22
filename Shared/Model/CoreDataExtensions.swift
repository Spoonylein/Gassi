//
//  CoreDataExtensions.swift
//  Gassi
//
//  Created by Jan Löffel on 23.07.23.
//

import Foundation
import CoreData

/// Enum of ID strings for default Gassi core data objects
enum GassiIDStrings: String {
    case peeType = "07031973-1000-6000-1000-000000001000"
    case pooType = "07031973-1000-6000-1100-000000002000"
}

extension GassiDog {

    private static var _current: GassiDog? = nil
    static var current: GassiDog {
        get {
            if _current == nil {
                return GassiDog()
            } else {
                return _current!
            }
        }
        set {
            if _current != newValue {
                let oldCurrentDog = _current
                _current = newValue
                
                if let newDog = _current {
                    newDog.managedObjectContext?.refresh(newDog, mergeChanges: true)
                }
                if let oldDog = oldCurrentDog {
                    oldDog.managedObjectContext?.refresh(oldDog, mergeChanges: true)
                }
                
                UserDefaults.standard.set(_current?.id?.uuidString, forKey: UserDefaultsKeys.currentDogIDString.rawValue)
                print("currentDogID \(_current?.id?.uuidString ?? "nil") saved in UserDefaults.")
            }
        }
    }
        
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewDog"), breed: GassiBreed? = nil, birthday: Date? = nil, sex: GassiSex? = nil, events: NSSet? = nil) -> GassiDog {
        let dog = GassiDog(context: context)
        
        dog.id = id
        dog.name = name
        dog.breed = breed
        dog.birthday = birthday
        dog.sex = sex
        if let _events = events { dog.addToEvents(_events) }
        
        return dog
    }
    
    var nameString: String {
        var result = localizedString("NamelessDog")
        
        if let name = self.name {
            result = name
        }
        
        return result
    }
    
    var breedNameString: String {
        var result = ""
        
        if let breed = self.breed {
            result = breed.nameString
        }
        
        return result
    }
    
    var sexNameString: String {
        var result = ""

        if let sex = self.sex {
            result = sex.nameString
        }
        
        return result
    }
    
    var ageString: String {
        var result = ""
        
        if let birthday = self.birthday, let years = Calendar.current.dateComponents([.year], from: birthday, to: .now).year {
            if years == 1 {
                result = "\(years)"
            } else {
                result = "\(years)"
            }
        }
        
        return result
    }
    
    var isCurrent: Bool {
        return GassiDog.current == self
    }
    
    func makeCurrent() {
        GassiDog.current = self
    }
}

extension GassiBreed {
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewBreed"), dogs: NSSet? = nil) -> GassiBreed {
        let breed = GassiBreed(context: context)

        breed.id = id
        breed.name = name
        if let _dogs = dogs { breed.addToDogs(_dogs) }
        
        return breed
    }
    
    var nameString: String {
        var result = localizedString("NamelessBreed")
        
        if let name = self.name {
            result = name
        }
        
        return result
    }

}

extension GassiSex {
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewSex"), dogs: NSSet? = nil) -> GassiSex {
        let sex = GassiSex(context: context)

        sex.id = id
        sex.name = name
        if let _dogs = dogs { sex.addToDogs(_dogs) }
        
        return sex
    }
    
    var nameString: String {
        var result = ""
        
        if let name = self.name {
            result = name
        }
        
        return result
    }
}

extension GassiType {
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = localizedString("NewType"), sign: String = localizedString("TypeSign"), predict: Bool = false, subtypes: NSSet? = nil, events: NSSet? = nil) -> GassiType {
        let type = GassiType(context: context)
        
        type.id = id
        type.name = name
        type.sign = sign
        type.predict = predict
        if let _subtypes = subtypes { type.addToSubtypes(_subtypes) }
        if let _events = events { type.addToEvents(_events) }
        
        return type
    }
    
    static func newPoo(context: NSManagedObjectContext) -> GassiType {
        return new(context: context, id: UUID(uuidString: GassiIDStrings.pooType.rawValue)!, name: "Poo", sign: "💩", predict: true)
    }
    
    static func newPee(context: NSManagedObjectContext) -> GassiType {
        return new(context: context, id: UUID(uuidString: GassiIDStrings.peeType.rawValue)!, name: "Pee", sign: "💦", predict: true)
    }
    
    private static var _poo: GassiType? = nil
    static var poo: GassiType {
        get {
            if _poo == nil {
                return GassiType()
            } else {
                return _poo!
            }
        }
        set {
            if _poo != newValue {
                _poo = newValue
            }
        }
    }

    private static var _pee: GassiType? = nil
    static var pee: GassiType {
        get {
            if _pee == nil {
                return GassiType()
            } else {
                return _pee!
            }
        }
        set {
            if _pee != newValue {
                _pee = newValue
            }
        }
    }

    var nameString: String {
        var result = ""
        
        if let name = self.name {
            result = name
        }
        
        return result
    }

}

extension GassiSubtype {
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = "new subtype", sign: String? = nil, type: GassiType?, events: NSSet? = nil) -> GassiSubtype {
        let subtype = GassiSubtype(context: context)
        
        subtype.id = id
        subtype.name = name
        subtype.sign = sign
        subtype.type = type
        if let _events = events { subtype.addToEvents(_events) }
        
        return subtype
    }
    
    static func newHardPoo(context: NSManagedObjectContext) -> GassiSubtype {
        return new(context: context, name: localizedString("HardPoo"), sign: localizedString("HardPooSign"), type: GassiType.poo)
    }
    
    static func newSoftPoo(context: NSManagedObjectContext) -> GassiSubtype {
        return new(context: context, name: localizedString("SoftPoo"), sign: localizedString("SoftPooSign"), type: GassiType.poo)
    }
    
    static func newDiarrheaPoo(context: NSManagedObjectContext) -> GassiSubtype {
        return new(context: context, name: localizedString("Diarrhea"), sign: localizedString("DiarrheaSign"), type: GassiType.poo)
    }
    
    private static var _hardPoo: GassiSubtype? = nil
    static var hardPoo: GassiSubtype {
        get {
            if _hardPoo == nil {
                return GassiSubtype()
            } else {
                return _hardPoo!
            }
        }
        set {
            if _hardPoo != newValue {
                _hardPoo = newValue
            }
        }
    }

    private static var _softPoo: GassiSubtype? = nil
    static var softPoo: GassiSubtype {
        get {
            if _softPoo == nil {
                return GassiSubtype()
            } else {
                return _softPoo!
            }
        }
        set {
            if _softPoo != newValue {
                _softPoo = newValue
            }
        }
    }

    private static var _diarrheaPoo: GassiSubtype? = nil
    static var diarrheaPoo: GassiSubtype {
        get {
            if _diarrheaPoo == nil {
                return GassiSubtype()
            } else {
                return _diarrheaPoo!
            }
        }
        set {
            if _diarrheaPoo != newValue {
                _diarrheaPoo = newValue
            }
        }
    }
    
    var nameString: String {
        var result = ""
        
        if let name = self.name {
            result = name
        }
        
        return result
    }

}

extension GassiEvent {
    static func new(context: NSManagedObjectContext, timestamp: Date = Date.now, dog: GassiDog, type: GassiType, subtype: GassiSubtype? = nil) -> GassiEvent {
        let event = GassiEvent(context: context)
        
        event.id = UUID()
        event.timestamp = timestamp
        event.dog = dog
        event.type = type
        event.subtype = subtype
        
        return event
    }
}
