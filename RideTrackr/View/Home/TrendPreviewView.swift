//
//  TrendPreviewView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/7/2024.
//

import SwiftUI

struct TrendPreviewView: View {
    
    @ObservedObject var trendManager: TrendManager = .shared
    @ObservedObject var navigationManager: NavigationManager = .shared
    @ObservedObject var settingsManager: SettingsManager = .shared
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
            
            HomeStatCardView(
                bgColor: .heartRate,
                title: "Average Heart Rate",
                icon: "heart.fill",
                data: Binding(get: { "\(String(format: "%.0f", trendManager.currentAverageHeartRate)) BMP" })
            )
            .onTapGesture {
                navigationManager.selectedTrendsTab = .HeartRate
                navigationManager.selectedTab = .Trends
            }
            
            HomeStatCardView(
                bgColor: .speed,
                title: "Average Speed",
                icon: "speedometer",
                data: Binding(get: { "\((trendManager.currentAverageSpeed * settingsManager.distanceUnit.distanceConversion).rounded()) \(settingsManager.distanceUnit.speedAbr)" })
            )
            .onTapGesture {
                navigationManager.selectedTrendsTab = .Speed
                navigationManager.selectedTab = .Trends
            }
            
            HomeStatCardView(
                bgColor: .distance,
                title: "Average Distance",
                icon: "figure.outdoor.cycle",
                data: Binding (get: { "\((trendManager.currentAverageDistance * settingsManager.distanceUnit.distanceConversion).rounded()) \(settingsManager.distanceUnit.distAbr)" })
            )
            .onTapGesture {
                navigationManager.selectedTrendsTab = .Distance
                navigationManager.selectedTab = .Trends
            }
            
            HomeStatCardView(
                bgColor: .energy,
                title: "Average Active Energy",
                icon: "flame.fill",
                data: Binding (get: { "\((trendManager.currentAverageEnergy * settingsManager.energyUnit.conversionValue).rounded()) \(settingsManager.energyUnit.abr)" })
            )
            .onTapGesture {
                navigationManager.selectedTrendsTab = .Energy
                navigationManager.selectedTab = .Trends
            }
            
            
        }
    }
}

#Preview {
    TrendPreviewView()
}
