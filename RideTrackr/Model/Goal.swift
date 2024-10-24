//
//  Goal.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 23/10/2024.
//

import Foundation
import SwiftUI

struct Goal: Identifiable, Hashable, Sendable, Codable, RawRepresentable {
    
    // MARK: - Properties
    
    var id: UUID
    var title: String
    var target: Double
    var current: Double
    var enabled: Bool = true
    var goalType: GoalType
    
    // MARK: - Computed Properties
    var progress: Double {
        current / target
    }
    
    var targetDisplay: String {
        
        switch goalType {
            case .Distance:
                let conversionValue = SettingsManager.shared.distanceUnit.distanceConversion
                
                return "\(Int((target * conversionValue).round(to: 2)))"
                
            case .Energy:
                let conversionValue = SettingsManager.shared.energyUnit.conversionValue
                
                return "\(Int(target * conversionValue))"
                
            case .Duration:
                return "\(Int(target))"
                
            case .Altitude:
                let conversionValue = SettingsManager.shared.distanceUnit.smallDistanceConversion
                
                return "\(Int((target * conversionValue).round(to: 1)))"
        }
    }
    
    var currentDisplay: String {
        
        switch goalType {
            case .Distance:
                let conversionValue = SettingsManager.shared.distanceUnit.distanceConversion
                
                return "\((current * conversionValue).round(to: 2))"
                
            case .Energy:
                let conversionValue = SettingsManager.shared.energyUnit.conversionValue
                
                return "\(Int(current * conversionValue))"
                
            case .Duration:
                return "\(Int(current))"
                
            case .Altitude:
                let conversionValue = SettingsManager.shared.distanceUnit.smallDistanceConversion
                
                return "\((current * conversionValue).round(to: 1))"
        }
    }
    
    // MARK: - Init
    init(id: UUID, title: String, target: Double, current: Double, goalType: GoalType) {
        self.id = id
        self.title = title
        self.target = target
        self.current = current
        self.goalType = goalType
    }
    
    
    //MARK: - RawRepresentable conformance
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else { return "" }
        return string
    }
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Goal.self, from: data)
        else { return nil }
        self = decoded
    }
}

// MARK: - GoalType
enum GoalType: String, Identifiable, CaseIterable {
    
    case Distance = "Distance"
    case Energy = "Energy"
    case Duration = "Duration"
    case Altitude = "Altitude"
    
    var id: GoalType { self }
    
    var color: Color {
        switch self {
            case .Distance: return .distance
            case .Energy: return .energy
            case .Duration: return .duration
            case .Altitude: return .altitude
        }
    }
    
    var icon: String {
        switch self {
            case .Distance: return "figure.outdoor.cycle"
            case .Energy: return "flame.fill"
            case .Duration: return "stopwatch"
            case .Altitude: return "mountain.2.circle"
        }
    }
    
    var unit: String {
        switch self {
            case .Distance: return SettingsManager.shared.distanceUnit.distAbr
            case .Energy: return SettingsManager.shared.energyUnit.abr
            case .Duration: return "mins"
            case .Altitude: return SettingsManager.shared.distanceUnit.smallDistanceAbr
        }
    }
    
}

// MARK: -  Default values
extension Goal {
    
    public static var defaultDistance: Self {
        
        return Self.init(id: UUID(), title: "Distance", target: GoalManager.distanceTarget, current: 0, goalType: .Distance)
    }
    
    public static var defaultEnergy: Self {
        
        return Self.init(id: UUID(), title: "Energy", target: GoalManager.energyTarget, current: 0, goalType: .Energy)
    }
    
    public static var defaultDuration: Self {
        
        return Self.init(id: UUID(), title: "Duration", target: GoalManager.durationTarget, current: 100, goalType: .Duration)
    }
    
    public static var defaultAltiudeGained: Self {
        
        return Self.init(id: UUID(), title: "Altiude Gained", target: GoalManager.altiudeTarget, current: 0, goalType: .Altitude)
    }
}