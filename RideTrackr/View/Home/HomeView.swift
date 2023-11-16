//
//  HomeView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData
import CoreData

struct HomeView: View {

    // MARK: - Properties
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var trendManager: TrendManager
    @EnvironmentObject var settingsManager: SettingsManager

    @Environment(\.modelContext) private var context
    @Query(sort: \Ride.rideDate, order: .reverse) var rides: [Ride]

    private var greetingString: String {
        return GetGreetingString()
    }

    // MARK: - body
    var body: some View {
        NavigationStack {

            ScrollView {
                VStack(alignment: .leading) {

                    // MARK: - stat views
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


                    // MARK: - recent ride preview
                    VStack(alignment: .leading) {

                        HStack(alignment: .bottom) {
                            Text("Your Last Ride")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.accent)

                            Spacer()

                            Text("Show more...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.accent)
                        }

                        if let recentRide = rides.first {


                            NavigationLink(value: recentRide) {
                                LargeRidePreview(ride: Binding(get: { recentRide }), queryingHealthKit: $healthManager.queryingHealthKit)
                            }.foregroundStyle(Color.primary)

                        } else {
                            LargeRidePreview(ride: Binding(get: { Ride() }), queryingHealthKit: $healthManager.queryingHealthKit)
                        }
                    }
                        .padding(.top)


                    // MARK: - recent ride cards


                    RecentRidesCardList()
                        .frame(height: 300)


                }.padding(.horizontal)

                // MARK: - toolbar
                .toolbar {

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            Task {

                                try! context.delete(model: Ride.self)
                                var syncedRides = await healthManager.syncRides(queryDate: .oneMonthAgo)
//                                syncedRides.forEach { $0.sortArrays() }
                                healthManager.rides = syncedRides
                            }
                        } label: {
                            Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        }
                        
                        Button("Test") {
//                            healthManager.testsdsf()
                            NotificationManager.shared.sendNotificaiton()
                        }
                    }
                }
                    .navigationTitle(greetingString)
            }
                .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }
        }
    }
}

// MARK: - Helper Functions
func GetGreetingString() -> String {

    let hour = Calendar.current.component(.hour, from: Date())

    switch hour {
    case 6..<12:
        return "Good morning"
    case 12..<18:
        return "Good afternoon"
    default:
        return "Good evening"
    }

}

// MARK: - Previews
#Preview("Home View") {
    HomeView().environmentObject(HealthManager())
        .environmentObject(TrendManager())
        .environmentObject(SettingsManager())
        .environmentObject(NavigationManager())
}

