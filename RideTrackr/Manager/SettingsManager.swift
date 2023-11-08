//
//  SettingsManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 26/10/2023.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    
    @AppStorage("distanceUnit") var distanceUnit: DistanceUnit = Locale.current.measurementSystem == Locale.MeasurementSystem.metric ? DistanceUnit.Metric : DistanceUnit.Imperial
    @AppStorage("energyUnit") var energyUnit: EnergyUnit = Locale.current.measurementSystem == Locale.MeasurementSystem.metric ? EnergyUnit.Kilojule : EnergyUnit.Calorie

}


/// Represents a unit of distance.
enum DistanceUnit: String, CaseIterable, Identifiable {
    
    /// The unit for kilometers.
    case Metric = "Metric"
    /// The unit for miles.
    case Imperial = "Imperial"
    
    var id: DistanceUnit { self }
    
    /// The conversion value of the distance unit. Used for converting values between the two units
    var distanceConversion: Double {
        switch self {
            case .Metric:
                return 1
            case .Imperial:
                return 0.621371
        }
    }
    
    /// The abbreviation of the distance unit.
    var distAbr: String {
        switch self {
            case .Metric:
                return "km"
            case .Imperial:
                return "mi"
        }
    }
    
    /// The abbreviation of the speed unit used
    var speedAbr: String {
        switch self {
            case .Metric:
                return "KM/H"
            case .Imperial:
                return "mph"
        }
    }
        
    /// The conversion value of the small distance unit. Used for converting values between the two units
    var smallDistanceConversion: Double {
        switch self {
            case .Metric:
                return 1
            case .Imperial:
                return 3.28084
        }
    }

    /// The abbreviation of the small distance unit
    var smallDistanceAbr: String {
        switch self {
            case .Metric:
                return "m"
            case .Imperial:
                return "ft"
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
