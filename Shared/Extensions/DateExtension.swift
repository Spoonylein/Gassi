//
//  DateExtension.swift
//  TiNo
//
//  Created by Jan Löffel on 08.09.21.
//

import Foundation

public extension Date {
    
    /// Converts the date and return it as a `String` in format "dd.MM.yyyy, HH:mm:ss".
    func toString() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy, HH:mm:ss"
        return dateformatter.string(from: self)
    }
    
    func relativeWeekday() -> String {
        // Setup the relative formatter
        let relDF = DateFormatter()
        relDF.doesRelativeDateFormatting = true
        relDF.dateStyle = .long
        relDF.timeStyle = .none
        
        // Setup the non-relative formatter
        let absDF = DateFormatter()
        absDF.dateStyle = .long
        absDF.timeStyle = .none
        
        // Get the result of both formatters
        let rel = relDF.string(from: self)
        let abs = absDF.string(from: self)
        
        // If the results are the same then it isn't a relative date.
        // Use your custom formatter. If different, return the relative result.
        if (rel == abs) {
            let weekdayFormatter: DateFormatter = {
                let df = DateFormatter()
                df.dateFormat = "EEEE"
                return df
            }()
            return weekdayFormatter.string(from: self)
        } else {
            return rel
        }
    }
    
    func weekday() -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        return df.string(from: self)
    }

}
