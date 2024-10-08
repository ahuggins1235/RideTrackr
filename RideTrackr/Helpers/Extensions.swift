//
//  Extensions.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/10/2023.
//

import Foundation
import SwiftUI
import MapKit
import HealthKit
import SwiftData

extension Binding {
    
    /// Creates a one-way binding for situations where you only need to be able to get data but never set it
    /// - Parameter get: The data that will act as a base for the binding
    init(get: @Sendable @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
    
}

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

extension MKCoordinateRegion {
    init?(from coordinates: [CLLocationCoordinate2D], buffer: Double) {
        guard coordinates.count > 1 else { return nil }
        
        let a = MKCoordinateRegion.region(coordinates, buffer: buffer, fix: { $0 }, fix2: { $0 })
        let b = MKCoordinateRegion.region(coordinates, buffer: buffer, fix: MKCoordinateRegion.fixMeridianNegativeLongitude, fix2: MKCoordinateRegion.fixMeridian180thLongitude)
        
        guard (a != nil || b != nil) else { return nil }
        guard (a != nil && b != nil) else {
            self = a ?? b!
            return
        }
        
        self = [a!, b!].min(by: { $0.span.longitudeDelta < $1.span.longitudeDelta }) ?? a!
    }
    
    var radius: CLLocationDistance {
        let furthest = CLLocation(latitude: self.center.latitude + (span.latitudeDelta / 2),
                                  longitude: center.longitude + (span.longitudeDelta / 2))
        return CLLocation(latitude: center.latitude, longitude: center.longitude).distance(from: furthest)
    }
    
    // MARK: - Private
    
    private static func region(_ coordinates: [CLLocationCoordinate2D], buffer: Double,
                               fix: (CLLocationCoordinate2D) -> CLLocationCoordinate2D,
                               fix2: (CLLocationCoordinate2D) -> CLLocationCoordinate2D) -> MKCoordinateRegion? {
        let t = coordinates.map(fix)
        let min = CLLocationCoordinate2D(latitude: t.min { $0.latitude < $1.latitude }!.latitude,
                                         longitude: t.min { $0.longitude < $1.longitude }!.longitude)
        let max = CLLocationCoordinate2D(latitude: t.max { $0.latitude < $1.latitude }!.latitude,
                                         longitude: t.max { $0.longitude < $1.longitude }!.longitude)
        
        // find span
        // multiply the deltas by 1.2 to create a buffer around the points
        let span = MKCoordinateSpan(latitudeDelta: (max.latitude - min.latitude) * buffer, longitudeDelta: (max.longitude - min.longitude) * buffer)
        
        // find center
        let center = CLLocationCoordinate2D(latitude: max.latitude - span.latitudeDelta / 2,
                                            longitude: max.longitude - span.longitudeDelta / 2)
        
        return MKCoordinateRegion(center: fix2(center), span: span)
    }
    
    private static func fixMeridianNegativeLongitude(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        guard (coordinate.longitude < 0) else { return coordinate }
        
        let fixedLng = 360 + coordinate.longitude
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: fixedLng)
    }
    
    private static func fixMeridian180thLongitude(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        guard (coordinate.longitude > 180) else { return coordinate }
        
        let fixedLng = -360 + coordinate.longitude
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: fixedLng)
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

extension String {
    static func placeholder(length: Int) -> String {
        String(Array(repeating: "X", count: length))
    }
}

extension View {
    @ViewBuilder
    func redacted(if condition: @autoclosure () -> Bool) -> some View {
        redacted(reason: condition() ? .placeholder : [])
    }
}

extension HKWorkout {
    static let emptyWorkout = HKWorkout(activityType: .cycling, start: Date(), end: Date())
}

extension Color {
    static func interpolate(from: Color, to: Color, proportion: Double) -> Color {
        let fromComponents = from.components()
        let toComponents = to.components()
        
        let r = fromComponents.red + (toComponents.red - fromComponents.red) * proportion
        let g = fromComponents.green + (toComponents.green - fromComponents.green) * proportion
        let b = fromComponents.blue + (toComponents.blue - fromComponents.blue) * proportion
        
        return Color(red: r, green: g, blue: b)
    }
    
    func components() -> (red: Double, green: Double, blue: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        
        return (red: Double(r), green: Double(g), blue: Double(b))
    }
}

//extension Color {
//    static func interpolate(from: Color, to: Color, proportion: Double) -> Color {
//        let fromComponents = from.components()
//        let toComponents = to.components()
//        
//        let r = fromComponents.red + (toComponents.red - fromComponents.red) * proportion
//        let g = fromComponents.green + (toComponents.green - fromComponents.green) * proportion
//        let b = fromComponents.blue + (toComponents.blue - fromComponents.blue) * proportion
//        
//        return Color(red: r, green: g, blue: b)
//    }
//    
//    func components() -> (red: Double, green: Double, blue: Double) {
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        
//        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
//        
//        return (red: Double(r), green: Double(g), blue: Double(b))
//    }
//}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0) // Default to black if input is invalid
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
