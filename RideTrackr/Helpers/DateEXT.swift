//
//  DateEXT.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//

import Foundation

extension Date {
    
    /// Checks if two dates are more than a year apart
    /// - Parameters:
    ///   - date1: The first date to check
    ///   - date2: The second date to check
    /// - Returns: True if the two dates are more than a year apart, false if they are not
    static func areDatesAYearApart(_ date1: Date, _ date2: Date) -> Bool {
        
        let components = Calendar.current.dateComponents([.month], from: date1, to: date2)
        
        if let months = components.month {
            return abs(months) >= 12
        }
        return false
    }
    
    /// gets the start of the current day
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    /// gets the monday at the beginning of the current week
    static var startOfWeekMonday: Date? {
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        var startOfTheWeek: Date = Date()
        var interval: TimeInterval = 0
        
        let _ = calendar.dateInterval(of: .weekOfYear, start: &startOfTheWeek, interval: &interval, for: currentDate)
        
        return startOfTheWeek
    }
    
    static var startOfMonth: Date {
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        var startOfTheMonth: Date = Date()
        var interval: TimeInterval = 0
        
        let _ = calendar.dateInterval(of: .month, start: &startOfTheMonth, interval: &interval, for: currentDate)
        
        return startOfTheMonth
    }
    
    static var startOfYear: Date {
        let calendar = Calendar.current
        
        
        let currentDate = Date()
        
        var startOfTheYear: Date = Date()
        var interval: TimeInterval = 0
        
        let _ = calendar.dateInterval(of: .year, start: &startOfTheYear, interval: &interval, for: currentDate)
        return startOfTheYear
    }
    
    static var sevenDaysAgo: Date {
        let calendar = Calendar.current
        let oneWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        return calendar.startOfDay(for: oneWeek!)
    }
    
    /// gets the date of the day one month agoi
    static var oneMonthAgo: Date {
        let calendar = Calendar.current
        let oneMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        return calendar.startOfDay(for: oneMonth!)
    }
    
    
    /// gets the date of the day three months ago
    static var threeMonthsAgo: Date {
        let calendar = Calendar.current
        let oneMonth = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        return calendar.startOfDay(for: oneMonth!)
    }
    
    /// gets the date of the day six months ago
    static var sixMonthsAgo: Date {
        let calendar = Calendar.current
        let oneMonth = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        return calendar.startOfDay(for: oneMonth!)
    }
    
    /// gets the date of the day one year ago
    static var oneYearAgo: Date {
        let calendar = Calendar.current
        let oneYear = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        return calendar.startOfDay(for: oneYear!)
    }
}

extension DateFormatter {
    
    /// Returns an ordinal suffix to depending on what day of the month is passed in
    func ordinalSuffix(for day: Int) -> String {
        
        switch day {
            case 1, 21, 31:
                return "st"
            case 2, 22:
                return "nd"
            case 3, 23:
                return "rd"
            default:
                return "th"
        }
    }
}
