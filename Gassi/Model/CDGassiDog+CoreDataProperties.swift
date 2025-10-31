//
//  CDGassiDog+CoreDataProperties.swift
//  Gassi
//
//  Created by Jan Löffel on 10.09.22.
//
//

import Foundation
import CoreData


extension CDGassiDog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGassiDog> {
        return NSFetchRequest<CDGassiDog>(entityName: "CDGassiDog")
    }

    // Core Data defined properties
    @NSManaged public var cd_birthDate: Date?
    @NSManaged public var cd_breed: String?
    @NSManaged public var cd_id: UUID?
    @NSManaged public var cd_name: String?
    @NSManaged public var cd_setting: CDGassiSettings?
    @NSManaged public var cd_events: NSSet?

    // These are the wrapper properties to use in real code. They set or get given core data property in easiest form.
    // It helps to avoid using `Optionals` when you really don't need to. And you may use special getters or setters.
    public var birthDate: Date? { get { return cd_birthDate } set { cd_birthDate = newValue } }
    public var breed: String { get { return cd_breed ?? NSLocalizedString("DogBreed", comment: "") } set { cd_breed = newValue } }
    public var id: UUID { get { return cd_id ?? UUID() } set { cd_id = newValue } }
    public var name: String { get { return cd_name ?? NSLocalizedString("Dog", comment: "") } set { cd_name = newValue } }
    public var setting: CDGassiSettings { get { return cd_setting ?? CDGassiSettings() } set { cd_setting = newValue } }
    public var events: [CDGassiEvent] {
        get {
            let set = cd_events as? Set<CDGassiEvent> ?? []
            return set.sorted { event1, event2 in
                event1.timestamp < event2.timestamp
            }
        }
        set {
            cd_events = NSSet(array: newValue)
        }
    }
}

// MARK: Generated accessors for cd_events
extension CDGassiDog {

    @objc(addCd_eventsObject:)
    @NSManaged public func addToCd_events(_ value: CDGassiEvent)

    @objc(removeCd_eventsObject:)
    @NSManaged public func removeFromCd_events(_ value: CDGassiEvent)

    @objc(addCd_events:)
    @NSManaged public func addToCd_events(_ values: NSSet)

    @objc(removeCd_events:)
    @NSManaged public func removeFromCd_events(_ values: NSSet)

}

extension CDGassiDog : Identifiable {

}
