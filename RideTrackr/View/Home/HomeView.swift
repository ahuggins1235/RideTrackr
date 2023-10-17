//
//  HomeView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct HomeView: View {

    // MARK: - Properties
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var trendManager: TrendManager

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

                        HomeStatCardView(bgColor: .heartRate, title: "Average Heart Rate", icon: "heart.fill", data: "\(trendManager.currentAverageHeartRate.rounded()) BMP")
                            .onTapGesture {
                                navigationManager.selectedTrendsTab = .HeartRate
                                navigationManager.selectedTab = .Trends
                            }
                        
                        HomeStatCardView(bgColor: .speed, title: "Average Speed", icon: "speedometer", data: "\(trendManager.currentAverageSpeed.rounded()) KM/H")
                            .onTapGesture {
                                navigationManager.selectedTrendsTab = .Speed
                                navigationManager.selectedTab = .Trends
                            }
                        
                        HomeStatCardView(bgColor: .distance, title: "Average Distance", icon: "figure.outdoor.cycle", data: "\(trendManager.currentAverageDistance.rounded()) KM")
                            .onTapGesture {
                                navigationManager.selectedTrendsTab = .Distance
                                navigationManager.selectedTab = .Trends
                            }
                        
                        HomeStatCardView(bgColor: .energy, title: "Average Active Energy", icon: "flame.fill", data: "\(trendManager.currentAverageEnergy.rounded()) KJ")
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

                        if let recentRide = healthManager.recentRide {
                            NavigationLink(value: recentRide) {
                                LargeRidePreview(ride: Binding(get: { recentRide }, set: { _ in }), queryingHealthKit: $healthManager.queryingHealthKit)
                            }.foregroundStyle(Color.primary)

                        } else {
                            LargeRidePreview(ride: Binding(get: { PreviewRide }, set: { _ in }), queryingHealthKit: $healthManager.queryingHealthKit)
                        }
                    }
                        .padding(.top)


                    // MARK: - recent ride cards

                    VStack(alignment: .leading) {

                        HStack {
                            Text("Recent Rides")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.accent)

                            Spacer()

                            Text("Show more...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.accent)
                                .onTapGesture {
                                navigationManager.selectedTab = .RideList
                            }

                        }

                        ScrollView(.horizontal) {

                            HStack() {
//                                    ForEach(previewRideArray.prefix(5).dropFirst()) { ride in
                                ForEach(healthManager.rides.prefix(5).dropFirst()) { ride in
                                    NavigationLink(value: ride) {
                                        RideCardPreview(ride: ride)

                                    }
                                        .foregroundStyle(Color.primary)
                                        .scrollTransition(.animated.threshold(.visible(0.3))) { content, phase in

                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.3)
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.3)

                                    }
                                }
                            }
                                .padding()
                                .scrollTargetLayout(isEnabled: true)
                        }
                            .scrollIndicators(.never)
                            .scrollTargetBehavior(.viewAligned)
                            .padding(.horizontal, -10)

                    }
                        .padding(.vertical)
                }.padding(.horizontal)

                // MARK: - toolbar
                .toolbar {

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            healthManager.syncWithHK()
                        } label: {
                            Label("Sync", systemImage: "arrow.triangle.2.circlepath")
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
}
