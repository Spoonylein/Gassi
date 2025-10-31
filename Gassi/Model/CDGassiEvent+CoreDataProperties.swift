//
//  CDGassiEvent+CoreDataProperties.swift
//  Gassi
//
//  Created by Jan Löffel on 01.10.22.
//
//

import Foundation
import CoreData


extension CDGassiEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGassiEvent> {
        return NSFetchRequest<CDGassiEvent>(entityName: "CDGassiEvent")
    }

    @NSManaged public var cd_id: UUID?
    @NSManaged public var cd_timestamp: Date?
    @NSManaged public var cd_latitude: Double
    @NSManaged public var cd_longitude: Double
    @NSManaged public var cd_category: CDGassiCategory?
    @NSManaged public var cd_dog: CDGassiDog?

    // These are the wrapper properties to use in real code. They set or get given core data property in easiest form.
    // It helps to avoid using `Optionals` when you really don't need to. And you may use special getters or setters.
    public var id: UUID { get { return cd_id ?? UUID() } set { cd_id = newValue } }
    public var timestamp: Date { get { return cd_timestamp ?? Date.now } set { cd_timestamp = newValue } }
    public var category: CDGassiCategory? { get { return cd_category } set { cd_category = newValue } }
    public var dog: CDGassiDog? { get { return cd_dog } set { cd_dog = newValue } }
    public var latitude: Double { get { return cd_latitude } set { cd_latitude = newValue} }
    public var longitude: Double { get { return cd_longitude } set { cd_longitude = newValue} }
}

extension CDGassiEvent : Identifiable {

}
