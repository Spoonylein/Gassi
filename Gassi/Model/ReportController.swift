//
//  ReportController.swift
//  Gassi
//
//  Created by Jan Löffel on 18.09.22.
//

import Foundation

class ReportController {
    
    static var reports: [ReportController] = []
    
    static func getReport(dog: CDGassiDog? = nil, category: CDGassiCategory? = nil) {
        
    }
    
    var dog: CDGassiDog? = nil
    var category: CDGassiCategory? = nil
    var eventCount: Int = 0
    var daysCount: Int = 0
    var eventDaysCount: Int = 0
    var maxEventsPerDay: Int = 0
    var avgEventsPerDay: Int = 0
    var minEventsPerDay: Int = 0
    var maxEventsDate: Date = Date()
    var minEventsDate: Date = Date()
    var maxDistancePerDay: TimeInterval = 0.0
    var avgDistancePerDay: TimeInterval = 0.0
    var minDistancePerDay: TimeInterval = 0.0
    var maxDistanceDate: Date = Date()
    var minDistanceDate: Date = Date()
}
