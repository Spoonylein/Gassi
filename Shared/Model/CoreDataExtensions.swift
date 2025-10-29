//
//  CoreDataExtensions.swift
//  Gassi
//
//  Created by Jan Löffel on 23.07.23.
//

import Foundation
import CoreData
import SwiftUI

/// Enum of ID strings for default Gassi core data objects
//enum GassiIDStrings: String {
//    case peeType = "07031973-1000-6000-1000-000000001000"
//    case pooType = "07031973-1000-6000-1100-000000002000"
//}

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

extension GassiBreed: Encodable {
    enum CodingKeys: CodingKey {
        case name
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
    }
    
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
    static let peeID: UUID = UUID(uuidString: "07031973-1000-6000-1000-000000001000")!
    static let pooID: UUID = UUID(uuidString: "07031973-1000-6000-1100-000000002000")!

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
        return new(context: context, id: GassiType.pooID, name: "Poo", sign: "💩", predict: true)
    }
    
    static func newPee(context: NSManagedObjectContext) -> GassiType {
        return new(context: context, id: GassiType.peeID, name: "Pee", sign: "💦", predict: true)
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
    
    var isPeeOrPoo: Bool {
        return self == GassiType.pee || self == GassiType.poo
    }

}

extension GassiSubtype {
    static func new(context: NSManagedObjectContext, id: UUID = UUID(), name: String = "new subtype", sign: String? = nil, type: GassiType, events: NSSet? = nil) -> GassiSubtype {
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
    
    static func newDiarrheaPoo(context: NSManagedObjectContext) -> GassiSubtype {
        return new(context: context, name: localizedString("Diarrhea"), sign: localizedString("DiarrheaSign"), type: GassiType.poo)
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
    static let defaultGracePeriod: TimeInterval = 15 * 60
    static let defaultTimespan: TimeInterval = 30 * 24 * 60 * 60

    private static var _gracePeriod: TimeInterval = defaultGracePeriod
    static var gracePeriod: TimeInterval {
        get {
            return _gracePeriod
        }
        set {
            if _gracePeriod != newValue {
                _gracePeriod = newValue
                
                UserDefaults.standard.set(_gracePeriod, forKey: UserDefaultsKeys.eventsGracePeriod.rawValue)
                print("eventsGracePeriod \(_gracePeriod) saved in UserDefaults.")
            }
        }
    }

    private static var _timespan: TimeInterval = defaultTimespan
    static var timespan: TimeInterval {
        get {
            return _timespan
        }
        set {
            if _timespan != newValue {
                _timespan = newValue
                
                UserDefaults.standard.set(_timespan, forKey: UserDefaultsKeys.eventsTimespan.rawValue)
                print("eventsTimespan \(_timespan) saved in UserDefaults.")
            }
        }
    }

    static func new(context: NSManagedObjectContext, timestamp: Date = Date.now, dog: GassiDog, type: GassiType, subtype: GassiSubtype? = nil) -> GassiEvent {
        // Check for a existing event within grace period and use it instead of creating a new event
        let fetchRequest: NSFetchRequest = GassiEvent.fetchRequest()
        let timestampPredicate: NSPredicate = NSPredicate(format: "timestamp > %@", Date.now.addingTimeInterval(-gracePeriod) as CVarArg)
        let dogPredicate: NSPredicate = NSPredicate(format: "dog == %@", dog)
        let typePredicate: NSPredicate = NSPredicate(format: "type == %@", type)
        let subtypePredicate: NSPredicate = (subtype != nil ? NSPredicate(format: "subtype == %@", subtype!) : NSPredicate(format: "subtype == NIL"))
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [timestampPredicate, dogPredicate, typePredicate, subtypePredicate])
        
        if let gracePeriodEvent = try? context.fetch(fetchRequest).first {
            gracePeriodEvent.timestamp = timestamp
            return gracePeriodEvent
        }
        
        let event = GassiEvent(context: context)
        event.id = UUID()
        event.timestamp = timestamp
        event.dog = dog
        event.type = type
        event.subtype = subtype
        
        groom(in: context)
        
        return event
    }
    
    static func groom(in viewContext: NSManagedObjectContext, to timespan: TimeInterval = GassiEvent.timespan) {
        // Delete all events older than `days`
        let fetchRequest: NSFetchRequest = GassiEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", Date.now.addingTimeInterval(-timespan) as CVarArg)
        
        if let events = try? viewContext.fetch(fetchRequest) {
            events.forEach(viewContext.delete)
        }
    }
    
    static func eventDays(events: [GassiEvent]) -> [Date] {
        var result: [Date] = []
        
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
            if !result.contains(day) { result.append(day) }
        }
        
        return result
    }
    
    static func daysCount(events: FetchedResults<GassiEvent>) -> Int {
        return eventDays(events: events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now < event2.timestamp ?? .now
        })).count
    }
    
    static func daysCount(events: [GassiEvent]) -> Int {
        var result: Int = 0
        
        var eventDays: [Date] = [Date]()    // Unique array of days with events
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
            if !eventDays.contains(day) { eventDays.append(day) }
        }
        result = eventDays.count
        
        return result
    }
    
    static func distancesSum(descendingSortedEvents: [GassiEvent]) -> TimeInterval {
        var result: TimeInterval = 0
        
        for (index, event) in descendingSortedEvents.enumerated() {
            if index < descendingSortedEvents.count - 1 {
                result += (descendingSortedEvents[index + 1].timestamp ?? .now).distance(to: event.timestamp ?? .now)
            }
        }
        
        print(result.formatted())
        return result
    }
    
    static func distancesSum(fetchedDescendingSortedEvents: FetchedResults<GassiEvent>) -> TimeInterval {
        var result: TimeInterval = 0

        for (index, event) in fetchedDescendingSortedEvents.enumerated() {
            if index > 0 {
                result += (event.timestamp ?? .now).distance(to: fetchedDescendingSortedEvents[index - 1].timestamp ?? .now)
            }
        }

        print(result.formatted())
        return result
    }
    
    static func eventsPerDayCount(events: [GassiEvent]) -> [Date:Int] {
        var result: [Date:Int] = [:]
        
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
            if !Calendar.current.isDateInToday(day) {
                if let count = result[day] {
                    result[day] = count + 1
                } else {
                    result[day] = 1
                }
            }
        }
        
        return result
    }
    
    static func minEventsCount(events: [GassiEvent]) -> (day: Date, eventCount: Int) {
        var minCount: Int = 0
        var minDate: Date = .now
        let epdc = eventsPerDayCount(events: events)
        
        for (index, day) in epdc.keys.enumerated() {
            if let count = epdc[day] {
                if index == 0 || count <= minCount {
                    minCount = count
                    minDate = day
                }
            }
        }
        
        return (minDate, minCount)
    }
    
    static func maxEventsCount(events: [GassiEvent]) -> (day: Date, eventCount: Int) {
        var maxCount: Int = 0
        var maxDate: Date = .now
        let epdc = eventsPerDayCount(events: events)
        
        for (index, day) in epdc.keys.enumerated() {
            if let count = epdc[day] {
                if index == 0 || count >= maxCount {
                    maxCount = count
                    maxDate = day
                }
            }
        }
        
        return (maxDate, maxCount)
    }
    
    static func minDistancePerDay(events: [GassiEvent]) -> [Date:TimeInterval] {
        var result: [Date:TimeInterval] = [:]
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        for (index,event) in dscSortedEvents.enumerated() {
            if index > 0 {
                let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
                if let previousEvent = event.previous(events: dscSortedEvents, dog: event.dog, category: event.type), !Calendar.current.isDateInToday(day) {
                    if let distance = result[day] {
                        result[day] = min(distance, (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now))
                    } else {
                        result[day] = (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now)
                    }
                }

            }
        }
        
        return result
    }

    static func maxDistancePerDay(events: [GassiEvent]) -> [Date:TimeInterval] {
        var result: [Date:TimeInterval] = [:]
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })

        for (index,event) in dscSortedEvents.enumerated() {
            if index > 0 {
                let day = Calendar.current.startOfDay(for: event.timestamp ?? .now)
                if let previousEvent = event.previous(events: dscSortedEvents, dog: event.dog, category: event.type), !Calendar.current.isDateInToday(day) {
                    if let distance = result[day] {
                        result[day] = max(distance, (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now))
                    } else {
                        result[day] = (previousEvent.timestamp ?? .now).distance(to: event.timestamp ?? .now)
                    }
                }
            }
        }
        
        return result
    }

    static func minDistance(events: [GassiEvent]) -> (day: Date, distance: TimeInterval)? {
        let minDistances = minDistancePerDay(events: events)
        if let minimum = minDistances.min(by: { a, b in
            return a.value < b.value
        }) {
            return (minimum.key, minimum.value)
        } else {
            return nil
        }
    }
    
    static func maxDistance(events: [GassiEvent]) -> (day: Date, distance: TimeInterval)? {
        let maxDistances = maxDistancePerDay(events: events)
        if let maximum = maxDistances.min(by: { a, b in
            return a.value > b.value
        }) {
            return (maximum.key, maximum.value)
        } else {
            return nil
        }
    }
    
    static func next(viewContext: NSManagedObjectContext, dog: GassiDog? = nil, intervals: Int = 6, minProbability: Double = 0.15) -> GassiEvent? {
        var result: GassiEvent? = nil
        
        let eventsFetchRequest = GassiEvent.fetchRequest()
        let eventsSortDescriptor = NSSortDescriptor(key: "cd_timestamp", ascending: false)
        eventsFetchRequest.sortDescriptors = [eventsSortDescriptor]
        
        let categoriesFetchRequest = GassiType.fetchRequest()
        let categoriesSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        categoriesFetchRequest.sortDescriptors = [categoriesSortDescriptor]
        
        // Save all gassi events of given dog in `allGassiEvents`, save all default gassi categories in allGassiDefaultCategories.
        if let allGassiEvents = try? viewContext.fetch(eventsFetchRequest).filter({ item in
            return (item.dog == dog || item.dog == nil || dog == nil)
        }), let allGassiDefaultCategories = try? viewContext.fetch(categoriesFetchRequest).filter({ item in
            return item.predict
        }) {
            
            // Iterate over all default categories
            for category in allGassiDefaultCategories {
                let categoryGassiEvents = allGassiEvents.filter { item in
                    return item.type == category
                }
                
                if let nextGassiDate = nextDate(events: categoryGassiEvents,
                                                intervals: intervals,
                                                eventDays: daysCount(events: allGassiEvents),
                                                minProbability: minProbability) {
                    if let nextEvent = result {
                        if nextGassiDate < nextEvent.timestamp ?? .now {
                            result = GassiEvent()
                            result?.dog = dog
                            result?.type = category
                            result?.timestamp = nextGassiDate
                        }
                    } else {
                        result = GassiEvent()
                        result?.dog = dog
                        result?.type = category
                        result?.timestamp = nextGassiDate
                    }
                }
            }
        }
        
        return result
    }
    
    static func nextDate(events: [GassiEvent], intervals: Int = 6, eventDays: Int, minProbability: Double = 0.15) -> Date? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        var nextGassiEventDate: Date? = nil
        print(#function)
        let lastGassiEvent = dscSortedEvents.first
        let interval = 86400 / max(intervals, 1)    // Length of one interval in seconds avoiding division by Zero
        var distancesSum = 0.0
        var numberOfGassis = 0
        var numberOfGassisInInterval: [Int] = Array(repeating: 0, count: intervals)   // Array with all gassi events per interval
        var gassiProbabilityInInterval: [Double] = Array(repeating: 0.0, count: intervals) // Array with all probabilities of gassi event per interval
        var gassiAvgDistToNextEventInInterval: [TimeInterval] = Array(repeating: 0.0, count: intervals) // Array with average distance to next event per interval
        
        // Sum up the distances per interval
        for (index, event) in dscSortedEvents.enumerated() {
            let secondsOnDay = Calendar.current.startOfDay(for: event.timestamp ?? .now).distance(to: event.timestamp ?? .now)
            let intervalIndex = Int(secondsOnDay) / interval
            numberOfGassisInInterval[intervalIndex] += 1
            
            if index > 0 {
                let distanceToNextEvent = (event.timestamp ?? .now).distance(to: dscSortedEvents[index - 1].timestamp ?? .now)
                //                            distance = min(distance, 86400)
                gassiAvgDistToNextEventInInterval[intervalIndex] += distanceToNextEvent
                distancesSum += distanceToNextEvent
                
#if DEBUG
                print(
                    "EventIndex: \(index) in Interval \(intervalIndex), \(event.timestamp?.formatted(date: .numeric, time: .shortened) ?? "nil"), Distance to next event: \(TimeInterval.timeSpanString(distanceToNextEvent))"
                )
#endif
                
            } else {
                
#if DEBUG
                print(
                    "EventIndex: \(index) in Interval \(intervalIndex), \(event.timestamp?.formatted(date: .numeric, time: .shortened) ?? "nil")"
                )
#endif
                
            }
        }
        
        // Fill the array of gassis and probabilities per interval
        for index in 0...(intervals - 1) {
            gassiAvgDistToNextEventInInterval[index] = gassiAvgDistToNextEventInInterval[index] / Double(max(numberOfGassisInInterval[index] - 1, 1))
            gassiProbabilityInInterval[index] = Double(max(0, numberOfGassisInInterval[index] - 1)) / Double(eventDays)
            numberOfGassis += numberOfGassisInInterval[index]
            
#if DEBUG
            print("# in Interval \(index): \(numberOfGassisInInterval[index]) events, avg distance to next event: \(TimeInterval.timeSpanString(gassiAvgDistToNextEventInInterval[index])), Probability: \(gassiProbabilityInInterval[index])")
#endif
            
        }
        
        // If there was a last Gassi event, calc the next event
        if let timestamp = lastGassiEvent?.timestamp {
            let secondsOnDay = Calendar.current.startOfDay(for: timestamp).distance(to: timestamp)
            let intervalIndex = Int(secondsOnDay) / interval
            let eventDate = gassiAvgDistToNextEventInInterval[intervalIndex] > 0 && gassiProbabilityInInterval[intervalIndex] > minProbability ? timestamp + gassiAvgDistToNextEventInInterval[intervalIndex] : timestamp + (distancesSum / Double(max(numberOfGassis - 1, 1)))
            
#if DEBUG
            print(eventDate.formatted())
#endif
            
            // Just use the calculated next event, if it has an minimum probability and more than 1 event
            if numberOfGassis > 1 && gassiProbabilityInInterval[intervalIndex] > minProbability {
                nextGassiEventDate = eventDate
            }
        }
        
        return nextGassiEventDate
    }
    
    func previous(events: [GassiEvent], dog: GassiDog? = nil, category: GassiType? = nil) -> GassiEvent? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        var result: GassiEvent? = nil
        
        if let currentIndex = dscSortedEvents.firstIndex(of: self), currentIndex + 1 <= dscSortedEvents.count - 1 {
            for index in (currentIndex + 1)...(dscSortedEvents.count - 1) {
                if (category == nil || dscSortedEvents[index].type == category) &&
                   (dog == nil || dscSortedEvents[index].dog == dog) {
                    result = dscSortedEvents[index]
                    break
                }
            }
        }
        
        print(self.timestamp ?? "nil", result?.timestamp ?? "nil")
        return result
    }
    
    func distanceToPrevious(events: [GassiEvent], dog: GassiDog? = nil, category: GassiType? = nil) -> TimeInterval? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp ?? .now > event2.timestamp ?? .now
        })
        var result: TimeInterval? = nil
        
        if let previousEvent = self.previous(events: dscSortedEvents, dog: dog, category: category) {
            result = (previousEvent.timestamp ?? .now).distance(to: self.timestamp ?? .now)
        }
        
        return result
    }


}
