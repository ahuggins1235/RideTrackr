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
