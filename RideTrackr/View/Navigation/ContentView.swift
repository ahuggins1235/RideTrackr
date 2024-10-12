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

            RideTrackrTabView()
        }
        .onAppear {
            withAnimation {
                initalise()
            }
        }
            .onOpenURL { url in
            let dateFormatter = DateFormatter()

            // Set the date format to match the string
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

            guard
            url.scheme == "ridetrackr",
                url.host == "ride",
                let date = dateFormatter.date(from: url.pathComponents[1])
                else {
                print("issue with url")
                return
            }
//            print(DataManager.shared.rides.first!.rideDate.timeIntervalSince1970)
//            print(date.timeIntervalSince1970)


            if let ride = DataManager.shared.rides.first(where: { abs($0.rideDate.timeIntervalSince(date)) < 1 }) {
                NavigationManager.shared.homeNavPath.append(ride)

                
            } else {
                print("Error finding ride")
            }
                
                
        }
    }

    func initalise() {
        Task {
//            dataManager.refreshRides()

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
