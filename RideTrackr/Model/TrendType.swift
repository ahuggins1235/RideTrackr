//
//  TrendType.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import Foundation
import SwiftUI

enum TrendType: String, CaseIterable, Identifiable {
    case HeartRate = "Heart Rate"
    case Speed = "Speed"
    case Distance = "Distance"
    case Energy = "Energy"
    
    var id: TrendType { self }
    
    @MainActor
    var destination: AnyView {
        
        switch self {
            case .HeartRate:
                return AnyView(TrendView(statType: self))
            case .Speed:
                return AnyView(TrendView(statType: self))
            case .Distance:
                return AnyView(TrendView(statType: self))
            case .Energy:
                return AnyView(TrendView(statType: self))
        }
        
    }
    
    @MainActor
    var label: AnyView {
        switch self {
            case .HeartRate:
                return AnyView(Label("Home", systemImage: "heart.fill").labelStyle(.iconOnly))
            case .Speed:
                return AnyView(Label("Speed", systemImage: "speedometer").labelStyle(.iconOnly))
            case .Distance:
                return AnyView(Label("Distance", systemImage: "figure.outdoor.cycle").labelStyle(.iconOnly))
            case .Energy:
                return AnyView(Label("Energy", systemImage: "flame.fill").labelStyle(.iconOnly))
        }
    }
    
    var selectionColour: Color {
        switch self {
            case .HeartRate:
                return Color.heartRate
            case .Speed:
                return Color.speed
            case .Distance:
                return Color.distance
            case .Energy:
                return Color.energy
        }
    }
}
