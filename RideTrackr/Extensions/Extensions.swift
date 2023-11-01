//
//  Extensions.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/10/2023.
//

import Foundation
import SwiftUI

extension Binding {
    
    /// Creates a one-way binding for situations where you only need to be able to get data but never set it
    /// - Parameter get: The data that will act as a base for the binding
    init(get: @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
    
}

extension Date {
    
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

