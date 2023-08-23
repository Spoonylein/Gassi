//
//  TimeIntervalExtension.swift
//  SpoonFW
//
//  Created by Jan Löffel on 07.11.21.
//

import Foundation

extension TimeInterval {
    
    /// Gets the days part in a time interval.
    /// - Parameter timeSpan: The time interval.
    /// - Returns: An `Int` containing the number of remaining days in the time interval.
    public static func getDays(_ timeSpan: TimeInterval) -> Int {
        let days = (Int)(timeSpan) / (24 * 60 * 60)
        return days
    }
    
    /// Gets the hours part in a time interval.
    /// - Parameter timeSpan: The time interval.
    /// - Returns: An `Int` containing the number of remaining hours in the time interval.
    public static func getHours(_ timeSpan: TimeInterval) -> Int {
        let remainder = (Int)(timeSpan) % (24 * 60 * 60)
        let hours = remainder / (60 * 60)
        return hours
    }
    
    /// Gets the minutes part in a time interval.
    /// - Parameter timeSpan: The time interval.
    /// - Returns: An `Int` containing the number of remaining minutes in the time interval.
    public static func getMinutes(_ timeSpan: TimeInterval) -> Int {
        var remainder = (Int)(timeSpan) % (24 * 60 * 60)
        remainder = remainder % (60 * 60)
        let minutes = remainder / 60
        return minutes
    }
    
    /// Gets the seconds part in a time interval.
    /// - Parameter timeSpan: The time interval.
    /// - Returns: An `Int` containing the number of remaining seconds in the time interval.
    public static func getSeconds(_ timeSpan: TimeInterval) -> Int {
        var remainder = (Int)(timeSpan) % (24 * 60 * 60)
        remainder = remainder % (60 * 60)
        let seconds = remainder % 60
        return seconds
    }
    
    /// Creates a new `TimeInterval` based on days, hours, minutes and seconds.
    /// - Parameters:
    ///   - day: The number of days in the new time interval.
    ///   - hour: The number of hours in the new time interval.
    ///   - minute: The number of minutes in the new time interval.
    ///   - second: The number of seconds in the new time interval.
    /// - Returns: The new `TimeInterval`.
    public static func timeSpan(day: Int = 0, hour: Int = 0, minute: Int = 0, second: Int = 0) -> TimeInterval {
        return (TimeInterval)(day * 24 * 60 * 60 + hour * 60 * 60 + minute * 60 + second)
    }
    
    /// Calc and return a `String` representing the given time interval.
    /// - Parameters:
    ///   - timeSpan: The time interval.
    ///   - academic: If `true`, the string is formatted as "", otherwise "".
    public static func timeSpanString(_ timeSpan: TimeInterval, academic: Bool = false, showSeconds: Bool = true, showNull: Bool = false, offset: TimeInterval = 0) -> String {
        var returnString: String = ""
        var days: Int = 0
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0
        
        days = getDays(timeSpan)
        hours = getHours(timeSpan)
        minutes = getMinutes(timeSpan)
        seconds = getSeconds(timeSpan)
        
        if showSeconds {
            if academic {
                
                if days > 0 { returnString += "\(days)\(localizedString("DaysUnit", standardString: "d"))" }
                if hours > 0 { returnString += (returnString.isEmpty ? "\(hours)\(localizedString("HoursUnit", standardString: "h"))" : " \(hours)\(localizedString("HoursUnit", standardString: "h"))"  ) }
                if minutes > 0 { returnString += returnString.isEmpty ? "\(minutes)\(localizedString("MinutesUnit", standardString: "m"))" : " \(minutes)\(localizedString("MinutesUnit", standardString: "m"))" }
                if seconds > 0 { returnString += returnString.isEmpty ? "\(seconds)\(localizedString("SecondsUnit", standardString: "s"))" : " \(seconds)\(localizedString("SecondsUnit", standardString: "s"))" }
                
            } else {
                
                if days > 0 {
                    let daysUnitString = localizedString("DaysUnit", standardString: "d")
                    returnString = String(format: "%0d\(daysUnitString) %0.2d:%0.2d:%0.2d", days, hours, minutes, seconds)
                } else if hours > 0 {
                    returnString = String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
                } else {
                    returnString = String(format: "%0.2d:%0.2d", minutes, seconds)
                }
            }
        } else {
            if academic {
                
                if days > 0 { returnString += "\(days)\(localizedString("DaysUnit", standardString: "d"))" }
                if hours > 0 { returnString += (returnString.isEmpty ? "\(hours)\(localizedString("HoursUnit", standardString: "h"))" : " \(hours)\(localizedString("HoursUnit", standardString: "h"))"  ) }
                if minutes > 0 { returnString += returnString.isEmpty ? "\(minutes)\(localizedString("MinutesUnit", standardString: "m"))" : " \(minutes)\(localizedString("MinutesUnit", standardString: "m"))" }
                
            } else {
                
                if days > 0 {
                    let daysUnitString = localizedString("DaysUnit", standardString: "d")
                    returnString = String(format: "%0d\(daysUnitString) %0.2d:%0.2d", days, hours, minutes)
                } else if hours > 0 {
                    returnString = String(format: "%0.2d:%0.2d", hours, minutes)
                } else {
                    returnString = String(format: "%0.2d:%0.2d", minutes)
                }
            }
        }
        
        if showNull && days == 0 && hours == 0 && minutes == 0 && seconds == 0 {
            returnString = "0"
        }
        
        if (offset != 0) {
            returnString += " +\(TimeInterval.timeSpanString(offset, academic: true))"
        }
        
        return returnString
    }
    
    /// Gets a string describing given time intervals.
    /// - Parameters:
    ///   - timeIntervals: An array of `TimeInterval` with time spans.
    ///   - maxIntervals: The number of time intervals to include in the returned string.
    /// - Returns: A `String` containing some or all of the time intervals.
    public static func getTimeIntervalsString(timeIntervals: [TimeInterval], maxIntervals: Int = 1) -> String {
        var returnString: String = ""
        var intervalsAreEqual: Bool = true
        var firstIntervalString: String = ""
        
        if timeIntervals.count > 1 {
            for index in 1...min(timeIntervals.count - 1, maxIntervals) {
                let timeSpan = timeIntervals[index]
                
                if index > 1 {
                    intervalsAreEqual = intervalsAreEqual && ((timeSpan - timeIntervals[index - 1]) == (timeIntervals[index - 1] - timeIntervals[index - 2]))
                }
                
                let alertString: String = TimeInterval.timeSpanString(timeSpan, academic: true)
                
                if alertString != "" {
                    if index > 1 {
                        returnString += "・\(alertString)"
                    } else {
                        returnString += "\(alertString)"
                        firstIntervalString = returnString
                    }
                }
            }
            
            if intervalsAreEqual {
                returnString = "\(timeIntervals.count - 1)x " + firstIntervalString
            }
        }
        
        return returnString
    }
    
}
