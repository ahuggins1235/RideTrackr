//
//  SettingsManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 26/10/2023.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    
    @AppStorage("distanceUnit") var distanceUnit: DistanceUnit = Locale.current.measurementSystem == Locale.MeasurementSystem.metric ? DistanceUnit.Kilometer : DistanceUnit.Miles
    @AppStorage("energyUnit") var energyUnit: EnergyUnit = Locale.current.measurementSystem == Locale.MeasurementSystem.metric ? EnergyUnit.Kilojule : EnergyUnit.Calorie

}


/// Represents a unit of distance.
enum DistanceUnit: String, CaseIterable, Identifiable {
    
    /// The unit for kilometers.
    case Kilometer = "Kilometers"
    /// The unit for miles.
    case Miles = "Miles"
    
    var id: DistanceUnit { self }
    
    /// The conversion value of the distance unit. Used for converting values between the two units
    var conversionValue: Double {
        switch self {
            case .Kilometer:
                return 1
            case .Miles:
                return 0.621371
        }
    }
    
    /// The abbreviation of the distance unit.
    var abr: String {
        switch self {
            case .Kilometer:
                return "km"
            case .Miles:
                return "mi"
        }
    }
}


/// Represents a unit of energy
enum EnergyUnit: String, CaseIterable, Identifiable {
    
    /// the unit for kilojule
    case Kilojule = "Kilojule"
    /// the unit for calorie
    case Calorie = "Calorie"
    
    var id: EnergyUnit { self }
    
    /// The conversion value of the energy unit. Used for converting values between the two units
    var conversionValue: Double {
        switch self {
            case .Kilojule:
                return 1
            case .Calorie:
                return 0.239006
        }
    }
    
    /// The abbreviation of the energy unit.
    var abr: String {
        switch self {
            case .Kilojule:
                return "KJ"
            case .Calorie:
                return "cal"
        }
    }
}
