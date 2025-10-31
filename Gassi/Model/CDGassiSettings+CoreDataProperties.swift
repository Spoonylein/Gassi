//
//  CDGassiSettings+CoreDataProperties.swift
//  Gassi
//
//  Created by Jan Löffel on 10.09.22.
//
//

import Foundation
import CoreData


extension CDGassiSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGassiSettings> {
        return NSFetchRequest<CDGassiSettings>(entityName: "CDGassiSettings")
    }

    // Core Data defined properties
    @NSManaged public var cd_gracePeriod: Double
    @NSManaged public var cd_groomingDays: Int16
    @NSManaged public var cd_id: UUID?
    @NSManaged public var cd_currentDog: CDGassiDog?
    @NSManaged public var cd_favoriteCategory1: CDGassiCategory?
    @NSManaged public var cd_favoriteCategory2: CDGassiCategory?

    // These are the wrapper properties to use in real code. They set or get given core data property in easiest form.
    // It helps to avoid using `Optionals` when you really don't need to. And you may use special getters or setters.
    public var gracePeriod: Double { get { return cd_gracePeriod } set { cd_gracePeriod = newValue } }
    public var groomingDays: Int16 { get { return cd_groomingDays } set { cd_groomingDays = newValue } }
    public var id: UUID { get { return cd_id ?? UUID() } set { cd_id = newValue } }
    public var currentDog: CDGassiDog? { get { return cd_currentDog } set { cd_currentDog = newValue } }
    public var favoriteCategory1: CDGassiCategory? { get { return cd_favoriteCategory1 } set { cd_favoriteCategory1 = newValue } }
    public var favoriteCategory2: CDGassiCategory? { get { return cd_favoriteCategory2 } set { cd_favoriteCategory2 = newValue } }
}

extension CDGassiSettings : Identifiable {

}
