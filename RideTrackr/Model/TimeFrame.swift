//
//  TimeFrame.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 23/10/2024.
//

import Foundation

enum TimeFrame: String, CaseIterable, Identifiable {
    case SevenDays = "7 Days"
    case Month = "Month"
    case Year = "Year"

    var id: TimeFrame { self }

    var dateOffset: Date {

        let calendar = Calendar.current

        switch self {
        case .SevenDays:
            return calendar.date(byAdding: .day, value: -7, to: Date())!
        case .Month:
            return calendar.date(byAdding: .month, value: -1, to: Date())!
        case .Year:
            return calendar.date(byAdding: .year, value: -1, to: Date())!
        }

    }
    
    var futureLabel: String {
        switch self {
            case .SevenDays:
                return "Week"
            case .Month:
                return "Month"
            case .Year:
                return "Year"
        }
    }
}
