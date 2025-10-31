//
//  CDGassiDogExtension.swift
//  Gassi
//
//  Created by Jan Löffel on 15.08.22.
//

import CoreData

extension CDGassiDog {
    
    // MARK: FetchRequests
    @nonobjc public class func fetchSortedRequest() -> NSFetchRequest<CDGassiDog> {
        let request: NSFetchRequest<CDGassiDog> = CDGassiDog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDGassiDog.cd_name, ascending: true)]
        return request
    }
    
    static func new(viewContext: NSManagedObjectContext, name: String = "[NewGassiDog]", breed: String = "[Dog]", birthDate: Date = .now) -> CDGassiDog {
        let newItem = CDGassiDog(context: viewContext)
        newItem.cd_id = UUID()
        newItem.cd_name = name
        newItem.cd_breed = breed
        newItem.cd_birthDate = birthDate
        
        return newItem
    }
}
