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
    @EnvironmentObject var navigationManager: NavigationManager
    @State var currentRide = UUID()
    @Environment(\.modelContext) var context
//    @Query(sort: \Ride.rideDate, order: .reverse) var rides: [Ride]

    var body: some View {

        NavigationStack {

            VStack {

                // MARK: - Header
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

                }.offset(y: 15)
                // MARK: - Tabview

                if dataManager.rides.count >= 2 {

                    TabView(selection: $currentRide.animation()) {

                        ForEach(dataManager.rides.prefix(5).dropFirst()) { ride in

                            NavigationLink(value: ride) {

                                RideCardPreview(ride: ride).padding(.horizontal).tag(ride.id)
                                    .foregroundStyle(Color.primary)
                                    .containerRelativeFrame(.vertical)
                            }
                        }
                    }.tabViewStyle(.page(indexDisplayMode: .never))

                    // MARK: - page indicator
                    HStack(spacing: -5) {

                        ForEach(dataManager.rides.prefix(5).dropFirst()) { ride in

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
                        Capsule()
                            .foregroundStyle(.ultraThinMaterial)

                    }
                    // set the idicator to the second ride
                    .onAppear {

                        currentRide = dataManager.rides[1].id

                    }
                } else {
                    Text("No recent rides found")
                        .padding()
                }

            }.padding(.vertical)
                .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }
        }
    }

}


#Preview {
    RecentRidesCardList().environmentObject(HealthManager()).environmentObject(NavigationManager()).padding()
}

struct RideCardPreview: View {

    @State var ride: Ride

    var body: some View {

        ZStack {

            Color.cardBackground
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(radius: 4, x: 2, y: 2)

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

                MapSnapshotView(location: CLLocationCoordinate2D(latitude: ride.routeData.first!.latitude, longitude: ride.routeData.first!.longitude), route: ride.routeData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .padding()
            }
        }
            .frame(height: 175)
    }
}

#Preview {
    RideCardPreview(ride: PreviewRide)
}
