//
//  NavigationManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import Foundation
import SwiftUI

// holds the name, destination and label for each view in the main tab view
enum ApplicationTab: String, CaseIterable, Identifiable {
    case Home = "Home"
    case RideList = "Ride List"
    case Trends = "Trends"
    case Settings = "Settings"
    

    var id: ApplicationTab { self }

    var destination: AnyView {
        switch self {
        case .Home:
            return AnyView(HomeView())
        case .RideList:
            return AnyView(RideListView())
        case .Trends:
            return AnyView(TrendsTabView())
        case .Settings:
            return AnyView(SettingsView())

        }
    }

    var label: AnyView {
        switch self {
        case .Home:
            return AnyView(Label("Home", systemImage: "house"))
        case .RideList:
            return AnyView(Label("Rides", image: "figure.cycle.square.stack"))
        case .Trends:
            return AnyView(Label("Trends", systemImage: "chart.line.uptrend.xyaxis"))
        case .Settings:
            return AnyView(Label("Settings", systemImage: "gear"))
        }
    }
}


enum TrendsTab: String, CaseIterable, Identifiable {
    case HeartRate = "Heart Rate"
    case Speed = "Speed"
    case Distance = "Distance"
    case Energy = "Energy"
    
    var id: TrendsTab { self }
    
    var destination: AnyView {
        
        switch self {
            case .HeartRate:
                return AnyView(Text(self.rawValue))
            case .Speed:
                return AnyView(Text(self.rawValue))
            case .Distance:
                return AnyView(Text(self.rawValue))
            case .Energy:
                return AnyView(Text(self.rawValue))
        }
        
    }
    
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


class NavigationManager: ObservableObject {

    @Published var selectedTab = ApplicationTab.Home
    @Published var selectedTrendsTab = TrendsTab.HeartRate
    @Published var rideListNavPath = NavigationPath()

}
