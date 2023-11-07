//
//  ContentView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var trendManager: TrendManager
    @Environment(\.modelContext) private var context
    @Query private var rides: [Ride]
    @State var showAlert: Bool = true

    var body: some View {


        VStack {
            if !healthManager.queryingHealthKit {
                RideTrackrTabView()
            } else {
                ZStack {

                    Rectangle()
                        .fill(.appIconColour.gradient)
                        .ignoresSafeArea()

                    VStack(spacing: 100) {

                        Image("AppIconBike")
                            .resizable()
                            .frame(width: 242.4, height: 138.6)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .shadow(radius: 10)

                        ProgressView {
                            Text("Loading data from HealthKit...")
                                .bold()
                        }
                            .foregroundStyle(.background)
                    }
                        .foregroundStyle(.primary)
                }
            }
        }
        .onAppear(perform: initializeRides)
//            .onAppear {
//
//            var syncedRides: [Ride] = rides
//
//            // if there are no rides found, fetch them from healthkit
//            if syncedRides.count == 0 {
//                Task {
//
//                    syncedRides = await healthManager.syncRides(queryDate: .oneMonthAgo)
//                    print(syncedRides.count)
//                }
//            }
//
//            // ensure the array properties of each ride are properly sorted
//            syncedRides.forEach { $0.sortArrays() }
//
//            healthManager.rides = syncedRides
//            healthManager.queryingHealthKit = false
//
//        }
        .onChange(of: healthManager.rides) { oldValue, newValue in

            for ride in newValue {
                trendManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                trendManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                trendManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                trendManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))

                context.insert(ride)
            }
        }
    }

    func initializeRides() {
        
        Task {
            
            // Fetch rides from SwiftData
            let swiftDataRides = rides
            
            // Check if there are zero rides in SwiftData
            if swiftDataRides.count == 0 {
                // Fetch rides from HealthKit
                let healthKitRides = await healthManager.syncRides(queryDate: .oneMonthAgo)
                
                // Store rides in SwiftData for persistence
                // Assuming saveRides is a function that saves rides to SwiftData
                //            saveRides(healthKitRides)
                
                DispatchQueue.main.async {
                    // Put rides into healthManager rides property
                    healthManager.rides = healthKitRides
                }
            } else {
                // If there are already rides in SwiftData
                // Call each ride's sortArrays function
                for index in 0..<swiftDataRides.count {
                    let ride = swiftDataRides[index]
//                    ride.sortArrays()
                    swiftDataRides[index].routeData = ride.routeData.sorted(by: { $0.timeStamp < $1.timeStamp })
                    swiftDataRides[index].hrSamples = ride.hrSamples.sorted(by: { $0.date < $1.date })
                    swiftDataRides[index].speedSamples = ride.speedSamples.sorted(by: { $0.date < $1.date })
                    swiftDataRides[index].altitdueSamples = ride.altitdueSamples.sorted(by: { $0.date < $1.date })
                }
                
                // Put rides into healthManager rides property
                healthManager.rides = swiftDataRides
            }
        }
        healthManager.queryingHealthKit = false
    }

}

//#Preview {
//    ContentView().environmentObject(HealthManager()).environmentObject(TrendManager())
//}
