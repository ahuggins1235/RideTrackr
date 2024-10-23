//
//  ContentView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData
import WidgetKit

@MainActor
struct ContentView: View {

    @ObservedObject var healthManager: HKManager = HKManager.shared
    @ObservedObject var dataManager: DataManager = DataManager.shared
    @ObservedObject var trendManager: TrendManager = TrendManager.shared
    @State var showAlert: Bool = true
    @State var selectedRide: Ride?
    @State var presentSheet: Bool = false

    var body: some View {

        VStack {

            RideTrackrTabView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("HandleDeeplink"))) { notification in
            if let url = notification.object as? URL {
                handleDeepLink(url: url)
            }
        }
        .sheet(item: $selectedRide) { ride in
            NavigationStack {
                
                    RideDetailView(ride: ride)
                
                
            }
        }

            .onAppear {
            withAnimation {
                initalise()
            }
        }
            .onOpenURL { url in
                
                handleDeepLink(url: url)
        }
    }
    
    private func handleDeepLink(url: URL) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        guard
            url.scheme == "ridetrackr",
            url.host == "ride",
            let date = dateFormatter.date(from: url.pathComponents[1])
        else {
            print("Issue with URL")
            return
        }
        
        if let ride = DataManager.shared.rides.first(where: { abs($0.rideDate.timeIntervalSince(date)) < 1 }) {
            selectedRide = ride
        } else {
            print("Error finding ride")
        }
    }

    func initalise() {
        Task {
//            dataManager.refreshRides()
            
//            if firstLaunch {
//                HKManager.shared.requestAuthorization()
//                DataManager.shared.reyncData()
//                firstLaunch = false
//                print(firstLaunch)
//            }
            
//            if dataManager.rides.count <= 5 {
//                dataManager.reyncData()
//            }

            for ride in dataManager.rides {
                trendManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                trendManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                trendManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                trendManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))

            }

            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    ContentView()
}
