//
//  ContentView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData

@MainActor
struct ContentView: View {

    @ObservedObject var healthManager: HKManager = HKManager.shared
    @ObservedObject var dataManager: DataManager = DataManager.shared
    @ObservedObject var trendManager: TrendManager = TrendManager.shared
    @State var showAlert: Bool = true

    var body: some View {

        VStack {

//            if !healthManager.queryingHealthKit {
                RideTrackrTabView()

//            } else {
//                ZStack {
//
//                    Rectangle()
//                        .fill(.appIconColour.gradient)
//                        .ignoresSafeArea()
//
//                    VStack(spacing: 100) {
//
//                        Image("AppIconBike")
//                            .resizable()
//                            .frame(width: 242.4, height: 138.6)
//                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                            .shadow(radius: 10)
//
//                        ProgressView {
//                            Text("Loading data from Apple Health...")
//                                .bold()
//                        }
//                            .foregroundStyle(.white)
//                    }
//                        .foregroundStyle(.primary)
//                }
//            }
        }
            .onAppear {
            withAnimation {
                initalise()
            }
        }
    }

    func initalise() {
        Task {
            dataManager.refreshRides()

            for ride in dataManager.rides {
                trendManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                trendManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                trendManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                trendManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))

            }
        }
    }
}

#Preview {
    ContentView()
}
