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
    @EnvironmentObject var trendManager: TrendManager
//    @Environment(\.modelContext) private var context
//    @Query private var rides: [Ride]
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
                            Text("Loading data from Apple Health...")
                                .bold()
                        }
                        .foregroundStyle(.white)
                    }
                        .foregroundStyle(.primary)
                }
            }
        }
            .onAppear(perform: initializeRides)
            .onChange(of: healthManager.rides) { oldValue, newValue in
            withAnimation {
                for ride in newValue {
                    trendManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                    trendManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                    trendManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                    trendManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))

//                    context.insert(ride)
                }
            }
        }
    }

    func initializeRides() {


        healthManager.queryingHealthKit = false
        Task {
            
            print(dataManager.getAllRides().count)
            
            healthManager.rides = await healthManager.getRides(numRides: 5)
            healthManager.queryingHealthKit = false
            
            for ride in healthManager.rides {
                
                dataManager.insertRide(ride)
            }
        }
    }
}

//#Preview {
//    ContentView().environmentObject(HealthManager()).environmentObject(TrendManager())
//}
