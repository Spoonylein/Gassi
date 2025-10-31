//
//  CDGassiTypeExtension.swift
//  Gassi
//
//  Created by Jan Löffel on 11.08.22.
//

import CoreData

extension CDGassiCategory {
        
    // MARK: FetchRequests
    @nonobjc public class func fetchSortedRequest() -> NSFetchRequest<CDGassiCategory> {
        let request: NSFetchRequest<CDGassiCategory> = CDGassiCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDGassiCategory.cd_name, ascending: true)]
        return request
    }

    static func categories(viewContext: NSManagedObjectContext) -> [CDGassiCategory] {
        let fetchRequest = CDGassiCategory.fetchSortedRequest()
        
        return try! viewContext.fetch(fetchRequest).sorted { category1, category2 in
            return category1.name < category2.name
        }
    }
        
    static func new(viewContext: NSManagedObjectContext, name: String = "[NewGassiCategory]", sign: String = "💩", isDefault: Bool = false) -> CDGassiCategory {
        let newItem = CDGassiCategory(context: viewContext)
        newItem.cd_id = UUID()
        newItem.cd_name = name
        newItem.cd_sign = sign
        newItem.cd_isDefault = isDefault
        
        return newItem
    }
    
    func lastEvent(events: [CDGassiEvent]) -> CDGassiEvent? {
        return events.sorted { event1, event2 in
            return event1.timestamp < event2.timestamp
        }.last
    }

    func firstEvent(events: [CDGassiEvent]) -> CDGassiEvent? {
        return events.sorted { event1, event2 in
            return event1.timestamp < event2.timestamp
        }.first
    }
}
