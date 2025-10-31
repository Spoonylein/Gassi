//
//  CDGassiEventExtension.swift
//  Gassi
//
//  Created by Jan Löffel on 11.08.22.
//

import CoreData
import SwiftUI

extension CDGassiEvent {
    
    struct GassiEvent {
        var dog: CDGassiDog? = nil
        var category: CDGassiCategory? = nil
        var timestamp: Date = Date.distantFuture
    }
    
    // MARK: FetchRequest
    @nonobjc public class func sortedFetchRequest(dog: CDGassiDog? = nil, category: CDGassiCategory? = nil, ascending: Bool = true) -> NSFetchRequest<CDGassiEvent> {
        let fetchRequest = NSFetchRequest<CDGassiEvent>(entityName: "CDGassiEvent")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDGassiEvent.cd_timestamp, ascending: ascending)]
        
        let dogPredicate: NSPredicate = {
            if let d = dog {
                return NSPredicate(format: "cd_dog.cd_id == %@ OR cd_dog.cd_id == nil", d.id as NSUUID)
            } else {
                return NSPredicate(value: true)
            }
        }()
        
        let categoryPredicate: NSPredicate = {
            if let c = category {
                return NSPredicate(format: "cd_category.cd_id == %@ OR cd_category.cd_id == nil", c.id as NSUUID)
            } else {
                return NSPredicate(value: true)
            }
        }()
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dogPredicate, categoryPredicate])
        
        return fetchRequest
    }
    
    static func eventsArray(events: FetchedResults<CDGassiEvent>) -> [CDGassiEvent] {
        return events.sorted { event1, event2 in
            return event1.timestamp < event2.timestamp
        }
    }
    
    static func new(viewContext: NSManagedObjectContext, dog: CDGassiDog? = nil, timestamp: Date = .now, category: CDGassiCategory? = nil, gracePeriod: TimeInterval = 900, latitude: Double = 0, longitude: Double = 0) -> CDGassiEvent {
        if let gassiEvents = try? viewContext.fetch(CDGassiEvent.fetchRequest()) {
            if let similarEvent: CDGassiEvent = gassiEvents.first(where: { item in
                (item.dog == dog) &&
                (item.category == category) &&
                ((item.timestamp.distance(to: timestamp)) < gracePeriod)
            }) {
                similarEvent.timestamp = timestamp
                return similarEvent
            }
        }
        
        let newItem = CDGassiEvent(context: viewContext)
        newItem.cd_id = UUID()
        newItem.cd_timestamp = timestamp
        newItem.cd_category = category
        newItem.cd_dog = dog
        newItem.cd_latitude = latitude
        newItem.cd_longitude = longitude
        
        groom(in: viewContext, to: CoreDataController.shared.settings.groomingDays)
        
        return newItem
    }
    
    static func groom(in viewContext: NSManagedObjectContext, to days: Int16 = 90) {
        // Delete all events older than `days`
        (try? viewContext.fetch(CDGassiEvent.fetchRequest()))?.filter { item in
            item.timestamp.distance(to: .now) > (Double(days) * 60 * 60 * 24)
        }.forEach(viewContext.delete)
    }
    
    static func eventDays(events: [CDGassiEvent]) -> [Date] {
        var result: [Date] = []
        
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp)
            if !result.contains(day) { result.append(day) }
        }
        
        return result
    }
    
    static func daysCount(events: FetchedResults<CDGassiEvent>) -> Int {
        return eventDays(events: events.sorted(by: { event1, event2 in
            return event1.timestamp < event2.timestamp
        })).count
    }
    
    static func daysCount(events: [CDGassiEvent]) -> Int {
        var result: Int = 0
        
        var eventDays: [Date] = [Date]()    // Unique array of days with events
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp)
            if !eventDays.contains(day) { eventDays.append(day) }
        }
        result = eventDays.count
        
        return result
    }
    
    static func distancesSum(descendingSortedEvents: [CDGassiEvent]) -> TimeInterval {
        var result: TimeInterval = 0
        
        for (index, event) in descendingSortedEvents.enumerated() {
            if index < descendingSortedEvents.count - 1 {
                result += descendingSortedEvents[index + 1].timestamp.distance(to: event.timestamp)
            }
        }
        
        print(result.formatted())
        return result
    }
    
    static func distancesSum(fetchedDescendingSortedEvents: FetchedResults<CDGassiEvent>) -> TimeInterval {
        var result: TimeInterval = 0
        
        for (index, event) in fetchedDescendingSortedEvents.enumerated() {
            if index > 0 {
                result += event.timestamp.distance(to: fetchedDescendingSortedEvents[index - 1].timestamp)
            }
        }
        
        print(result.formatted())
        return result
    }
    
    static func eventsPerDayCount(events: [CDGassiEvent]) -> [Date:Int] {
        var result: [Date:Int] = [:]
        
        for event in events {
            let day = Calendar.current.startOfDay(for: event.timestamp)
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
    
    static func minEventsCount(events: [CDGassiEvent]) -> (day: Date, eventCount: Int) {
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
    
    static func maxEventsCount(events: [CDGassiEvent]) -> (day: Date, eventCount: Int) {
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
    
    static func minDistancePerDay(events: [CDGassiEvent]) -> [Date:TimeInterval] {
        var result: [Date:TimeInterval] = [:]
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp > event2.timestamp
        })

        for (index,event) in dscSortedEvents.enumerated() {
            if index > 0 {
                let day = Calendar.current.startOfDay(for: event.timestamp)
                if let previousEvent = event.previous(events: dscSortedEvents, dog: event.dog, category: event.category), !Calendar.current.isDateInToday(day) {
                    if let distance = result[day] {
                        result[day] = min(distance, previousEvent.timestamp.distance(to: event.timestamp))
                    } else {
                        result[day] = previousEvent.timestamp.distance(to: event.timestamp)
                    }
                }

            }
        }
        
        return result
    }

    static func maxDistancePerDay(events: [CDGassiEvent]) -> [Date:TimeInterval] {
        var result: [Date:TimeInterval] = [:]
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp > event2.timestamp
        })

        for (index,event) in dscSortedEvents.enumerated() {
            if index > 0 {
                let day = Calendar.current.startOfDay(for: event.timestamp)
                if let previousEvent = event.previous(events: dscSortedEvents, dog: event.dog, category: event.category), !Calendar.current.isDateInToday(day) {
                    if let distance = result[day] {
                        result[day] = max(distance, previousEvent.timestamp.distance(to: event.timestamp))
                    } else {
                        result[day] = previousEvent.timestamp.distance(to: event.timestamp)
                    }
                }
            }
        }
        
        return result
    }

    static func minDistance(events: [CDGassiEvent]) -> (day: Date, distance: TimeInterval)? {
        let minDistances = minDistancePerDay(events: events)
        if let minimum = minDistances.min(by: { a, b in
            return a.value < b.value
        }) {
            return (minimum.key, minimum.value)
        } else {
            return nil
        }
    }
    
    static func maxDistance(events: [CDGassiEvent]) -> (day: Date, distance: TimeInterval)? {
        let maxDistances = maxDistancePerDay(events: events)
        if let maximum = maxDistances.min(by: { a, b in
            return a.value > b.value
        }) {
            return (maximum.key, maximum.value)
        } else {
            return nil
        }
    }
    
    static func next(viewContext: NSManagedObjectContext, dog: CDGassiDog? = nil, intervals: Int = 6, minProbability: Double = 0.15) -> GassiEvent? {
        var result: GassiEvent? = nil
        
        let eventsFetchRequest = CDGassiEvent.fetchRequest()
        let eventsSortDescriptor = NSSortDescriptor(key: "cd_timestamp", ascending: false)
        eventsFetchRequest.sortDescriptors = [eventsSortDescriptor]
        
        let categoriesFetchRequest = CDGassiCategory.fetchRequest()
        let categoriesSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        categoriesFetchRequest.sortDescriptors = [categoriesSortDescriptor]
        
        // Save all gassi events of given dog in `allGassiEvents`, save all default gassi categories in allGassiDefaultCategories.
        if let allGassiEvents = try? viewContext.fetch(eventsFetchRequest).filter({ item in
            return (item.dog == dog || item.dog == nil || dog == nil)
        }), let allGassiDefaultCategories = try? viewContext.fetch(categoriesFetchRequest).filter({ item in
            return item.isDefault
        }) {
            
            // Iterate over all default categories
            for category in allGassiDefaultCategories {
                let categoryGassiEvents = allGassiEvents.filter { item in
                    return item.category == category
                }
                
                if let nextGassiDate = nextDate(events: categoryGassiEvents,
                                                intervals: intervals,
                                                eventDays: daysCount(events: allGassiEvents),
                                                minProbability: minProbability) {
                    if let nextEvent = result {
                        if nextGassiDate < nextEvent.timestamp { result = GassiEvent(dog: dog, category: category, timestamp: nextGassiDate) }
                    } else {
                        result = GassiEvent(dog: dog, category: category, timestamp: nextGassiDate)
                    }
                }
            }
        }
        
        return result
    }
    
    static func nextDate(events: [CDGassiEvent], intervals: Int = 6, eventDays: Int, minProbability: Double = 0.15) -> Date? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp > event2.timestamp
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
            let secondsOnDay = Calendar.current.startOfDay(for: event.timestamp).distance(to: event.timestamp)
            let intervalIndex = Int(secondsOnDay) / interval
            numberOfGassisInInterval[intervalIndex] += 1
            
            if index > 0 {
                let distanceToNextEvent = event.timestamp.distance(to: dscSortedEvents[index - 1].timestamp)
                //                            distance = min(distance, 86400)
                gassiAvgDistToNextEventInInterval[intervalIndex] += distanceToNextEvent
                distancesSum += distanceToNextEvent
                
#if DEBUG
                print("EventIndex: \(index) in Interval \(intervalIndex), \(event.timestamp.formatted(date: .numeric, time: .shortened)), Distance to next event: \(TimeInterval.timeSpanString(distanceToNextEvent))")
#endif
                
            } else {
                
#if DEBUG
                print("EventIndex: \(index) in Interval \(intervalIndex), \(event.timestamp.formatted(date: .numeric, time: .shortened))")
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
    
    func previous(events: [CDGassiEvent], dog: CDGassiDog? = nil, category: CDGassiCategory? = nil) -> CDGassiEvent? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp > event2.timestamp
        })
        var result: CDGassiEvent? = nil
        
        if let currentIndex = dscSortedEvents.firstIndex(of: self), currentIndex + 1 <= dscSortedEvents.count - 1 {
            for index in (currentIndex + 1)...(dscSortedEvents.count - 1) {
                if (category == nil || dscSortedEvents[index].category == category) &&
                   (dog == nil || dscSortedEvents[index].dog == dog) {
                    result = dscSortedEvents[index]
                    break
                }
            }
        }
        
        print(self.timestamp, result?.timestamp)
        return result
    }
    
    func distanceToPrevious(events: [CDGassiEvent], dog: CDGassiDog? = nil, category: CDGassiCategory? = nil) -> TimeInterval? {
        let dscSortedEvents = events.sorted(by: { event1, event2 in
            return event1.timestamp > event2.timestamp
        })
        var result: TimeInterval? = nil
        
        if let previousEvent = self.previous(events: dscSortedEvents, dog: dog, category: category) {
            result = previousEvent.timestamp.distance(to: self.timestamp)
        }
        
        return result
    }
}

