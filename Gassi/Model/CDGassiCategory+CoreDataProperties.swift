//
//  CDGassiCategory+CoreDataProperties.swift
//  Gassi
//
//  Created by Jan Löffel on 29.09.22.
//
//

import Foundation
import CoreData


extension CDGassiCategory {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGassiCategory> {
        return NSFetchRequest<CDGassiCategory>(entityName: "CDGassiCategory")
    }
    
    // Core Data defined properties
    @NSManaged public var cd_id: UUID?
    @NSManaged public var cd_isDefault: Bool
    @NSManaged public var cd_name: String?
    @NSManaged public var cd_sign: String?
    @NSManaged public var cd_events: NSSet?
    @NSManaged public var cd_favorite1InSetting: CDGassiSettings?
    @NSManaged public var cd_favorite2InSetting: CDGassiSettings?
    
    // These are the wrapper properties to use in real code. They set or get given core data property in easiest form.
    // It helps to avoid using `Optionals` when you really don't need to. And you may use special getters or setters.
    public var id: UUID { get { return cd_id ?? UUID() } set { cd_id = newValue } }
    public var isDefault: Bool { get { return cd_isDefault } set { cd_isDefault = newValue } }
    public var name: String { get { return cd_name ?? NSLocalizedString("Category", comment: "") } set { cd_name = newValue } }
    public var sign: String { get { return cd_sign ?? "🐕" } set { cd_sign = newValue } }
    public var events: NSSet { get { return cd_events ?? NSSet() } set { cd_events = newValue } }
    public var favorite1InSetting: CDGassiSettings { get { return cd_favorite1InSetting ?? CDGassiSettings() } set { cd_favorite1InSetting = newValue } }
    public var favorite2InSetting: CDGassiSettings { get { return cd_favorite2InSetting ?? CDGassiSettings() } set { cd_favorite2InSetting = newValue } }
    
}

// MARK: Generated accessors for cd_events
extension CDGassiCategory {
    
    @objc(addCd_eventsObject:)
    @NSManaged public func addToCd_events(_ value: CDGassiEvent)
    
    @objc(removeCd_eventsObject:)
    @NSManaged public func removeFromCd_events(_ value: CDGassiEvent)
    
    @objc(addCd_events:)
    @NSManaged public func addToCd_events(_ values: NSSet)
    
    @objc(removeCd_events:)
    @NSManaged public func removeFromCd_events(_ values: NSSet)
    
}

extension CDGassiCategory : Identifiable {
    
}

