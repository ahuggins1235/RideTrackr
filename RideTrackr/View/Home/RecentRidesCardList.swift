//
//  RecentRidesCardList.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 1/11/2023.
//

import SwiftUI
import MapKit
import SwiftData
import CoreData

struct RecentRidesCardList: View {

    @ObservedObject var healthManager: HKManager = .shared
    @ObservedObject var dataManager: DataManager = .shared
    @ObservedObject var navigationManager: NavigationManager = .shared
    @State var currentRide = UUID()
    var recentRides: [Ride] {

        let rideSlice = healthManager.queryingHealthKit ? previewRideArray.prefix(5).dropFirst() : dataManager.rides.prefix(5).dropFirst()
        var rides: [Ride] = []

        for ride in rideSlice {
            rides.append(ride)
        }
        return rides
    }

    var body: some View {

        NavigationStack {

            VStack {

                // MARK: - Header
                HStack {
                    Text("Recent Rides")
                        .font(.headline)
                        .bold()

                    Spacer()

                    Text("Show more...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .onTapGesture {
                        navigationManager.selectedTab = .RideList
                    }
                }
//                    .offset(y: 15)
                .foregroundStyle(.accent)

                // MARK: - Tabview

                if recentRides.count >= 2 {

                    TabView(selection: $currentRide.animation()) {

                        ForEach(recentRides) { ride in

                            NavigationLink(value: ride) {

                                RideCardPreview(ride: ride)
                                    .padding(.horizontal)
                                    .tag(ride.id)
                                    .foregroundStyle(Color.primary)
//                                    .containerRelativeFrame(.vertical)
                                .redacted(if: healthManager.queryingHealthKit)
                                    .shimmer(ShimmerConfig.defaultConfig, isLoading: healthManager.queryingHealthKit)
                            }
                        }
                    }
                    .frame(height: 175)
                        .tabViewStyle(.page(indexDisplayMode: .never))


                    // MARK: - page indicator
                    HStack(spacing: -5) {

                        ForEach(recentRides) { ride in

                            Circle().foregroundStyle(ride.id == currentRide ? Color.primary : Color.secondary)
                                .frame(height: ride.id == currentRide ? 10 : 7)
                                .padding(7)
                                .onTapGesture {
                                withAnimation {
                                    currentRide = ride.id
                                }
                            }
                        }
                    }.background {
                        Color.cardBackground.clipShape(Capsule())

                    }
                    // set the idicator to the second ride
                    .onAppear {

                        if dataManager.rides.count >= 2 {
                            currentRide = dataManager.rides[1].id
                        }
                    }
                } else {
                    Text("No recent rides found")
                        .padding()
                }
            }
//                .padding(.vertical)

                .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }
        }
    }
}


#Preview {
    RecentRidesCardList().padding()
}

struct RideCardPreview: View {

    @State var ride: Ride

    var body: some View {

        HStack {
            VStack(alignment: .center, spacing: 10) {

                Text(ride.dateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(spacing: 5) {
                    Text(ride.distanceString)
                        .foregroundStyle(.distance)

                    Text(ride.activeEnergyString)
                        .foregroundStyle(.energy)

                }.bold()
                    .font(.headline)
                    .padding(.vertical)

                Text(ride.durationString)
                    .fontWeight(.semibold)

            }
                .padding(.leading)

            if let _ = ride.routeData.first {
                SmallMapPreviewView(location: CLLocationCoordinate2D(latitude: ride.routeData.first!.latitude, longitude: ride.routeData.first!.longitude), route: ride.routeData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .padding()
                    .frame(height: 175)
            }
        }
            .background(.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .contentShape(Rectangle())
    }
}

#Preview {
    RideCardPreview(ride: PreviewRide)
}
