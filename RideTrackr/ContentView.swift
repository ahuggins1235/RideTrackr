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
        .onAppear {
            if rides.count == 0 {
                Task {
                    
                    
                        
                        let syncedRides = await healthManager.syncRides(queryDate: .oneMonthAgo)
                    healthManager.rides = syncedRides
//                        for ride in syncedRides {
//                            print(ride.rideDate)
//                            context.insert(ride)
//                            
//                        }
//                    showAlert = true
//                    print(syncedRides.first!.routeData.count)
                    
                }
            }
            
            healthManager.queryingHealthKit = false
        }
            .onChange(of: healthManager.rides) { oldValue, newValue in
                
            for ride in newValue {
                trendManager.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                trendManager.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                trendManager.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                trendManager.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))
                
                context.insert(ride)
            }
        }
//            .alert("\(healthManager.rides.first?.routeData.count ?? 0)", isPresented: $showAlert) {
                
//            }
    }
}

//#Preview {
//    ContentView().environmentObject(HealthManager()).environmentObject(TrendManager())
//}
