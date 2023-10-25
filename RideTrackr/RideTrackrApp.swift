//
//  RideTrackrApp.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

@main
struct RideTrackrApp: App {
    
    @StateObject var trendsManager: TrendManager = TrendManager()
    @StateObject var healthManager = HealthManager()
    @StateObject var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trendsManager)
                .environmentObject(healthManager)
                .environmentObject(navigationManager)
                .onAppear {
                    
//                    Task {
//                        do {
//                            await healthManager.syncWithHK()
//                            
//                            for ride in healthManager.rides {
//                                trendsManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
//                                trendsManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
//                                trendsManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
//                                trendsManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))
//                            }
//                        }
//                    }
                    
                    
                }
                
        }
    }
}
