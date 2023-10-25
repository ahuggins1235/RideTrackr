//
//  ContentView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var trendManager: TrendManager

    var body: some View {


        VStack {
            if !healthManager.queryingHealthKit {
                RideTrackrTabView()
            } else {
                ZStack {

                    Rectangle()
                        .fill(.background)
                        .ignoresSafeArea()

                    ProgressView {
                        Text("Loading data from healthkit...")

                    }
                        .foregroundStyle(.primary)
                }
            }
        }
            .onChange(of: healthManager.rides) { oldValue, newValue in
                
            for ride in newValue {
                trendManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                trendManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                trendManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                trendManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))

            }
        }
    }
}

//#Preview {
//    ContentView()
//}
