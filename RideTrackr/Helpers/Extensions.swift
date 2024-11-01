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
import Combine
import WidgetKit

extension Binding {
    
    /// Creates a one-way binding for situations where you only need to be able to get data but never set it
    /// - Parameter get: The data that will act as a base for the binding
    init(get: @Sendable @escaping () -> Value) {
        self.init(get: get, set: { _ in })
    }
}

extension String {
    static func placeholder(length: Int) -> String {
        String(Array(repeating: "X", count: length))
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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


@propertyWrapper
struct SharedAppStorage<T: PropertyListValue>: DynamicProperty {
    private let key: String
    private let defaultValue: T
    private let container: UserDefaults
    
    init(wrappedValue: T, _ key: String) {
        let groupID = "group.com.AndrewHuggins.RideTrackr"  // Replace with your App Group ID
        guard let container = UserDefaults(suiteName: groupID) else {
            fatalError("Failed to get shared UserDefaults container")
        }
        self.container = container
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    var wrappedValue: T {
        get {
            container.object(forKey: key) as? T ?? defaultValue
        }
        nonmutating set {
            container.set(newValue, forKey: key)
            // Trigger widget refresh
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    var projectedValue: Binding<T> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

// Protocol to constrain acceptable types
protocol PropertyListValue {}
extension String: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Date: PropertyListValue {}
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
extension DistanceUnit: PropertyListValue {}
extension EnergyUnit: PropertyListValue {}
