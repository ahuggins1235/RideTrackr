//
//  Goal.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 23/10/2024.
//

import Foundation
import SwiftUI

struct Goal: Identifiable, Hashable, Sendable, Codable, RawRepresentable {
    
    var id: UUID
    var title: String
    var target: Double
    var current: Double
    var unit: String
    var colour: Color
    var icon: String
    var enabled: Bool = true
    
    init(id: UUID, title: String, target: Double, current: Double, unit: String, colour: Color, icon: String) {
        self.id = id
        self.title = title
        self.target = target
        self.current = current
        self.unit = unit
        self.colour = colour
        self.icon = icon
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

extension Goal {
    
    public static var defaultDistance: Self {
        
        let conversionValue = SettingsManager.shared.distanceUnit.distanceConversion
        let unit = SettingsManager.shared.distanceUnit.distAbr
        return Self.init(id: UUID(), title: "Distance", target: 100 * conversionValue, current: 0, unit: unit, colour: .distance, icon: "figure.outdoor.cycle")
    }
    
    public static var defaultEnergy: Self {
        
        let conversionValue = SettingsManager.shared.energyUnit.conversionValue
        let unit = SettingsManager.shared.energyUnit.abr
        return Self.init(id: UUID(), title: "Energy", target: 5000 * conversionValue, current: 0, unit: unit, colour: .energy, icon: "flame.fill")
    }
    
    public static var defaultDuration: Self {
        
        return Self.init(id: UUID(), title: "Duration", target: 200, current: 0, unit: "mins", colour: .duration, icon: "stopwatch")
    }
    
    public static var defaultAltiudeGained: Self {
        
        let conversionValue = SettingsManager.shared.distanceUnit.smallDistanceConversion
        let unit = SettingsManager.shared.distanceUnit.smallDistanceAbr
        return Self.init(id: UUID(), title: "Altiude Gained", target: 50 * conversionValue, current: 0, unit: unit, colour: .altitude, icon: "mountain.2.circle")
    }
}
