//
//  NavigationManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import Foundation
import SwiftUI

/// holds the name, destination and label for each view in the main tab view
enum ApplicationTab: String, CaseIterable, Identifiable {
    case Home = "Home"
    case RideList = "Ride List"
    case Trends = "Trends"
    case Settings = "Settings"
    

    var id: ApplicationTab { self }
    
    @MainActor
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


class NavigationManager: ObservableObject {

    @Published var selectedTab = ApplicationTab.Home
    @Published var selectedTrendsTab = TrendType.HeartRate
    @Published var rideListNavPath = NavigationPath()

}
