//
//  RecentRidesCardList.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 1/11/2023.
//

import SwiftUI

struct RecentRidesCardList: View {

    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State var currentPage = 0

    var body: some View {

        NavigationStack {

            VStack {

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
                TabView(selection: $currentPage.animation()) {
                                    ForEach(0..<previewRideArray.prefix(5).dropFirst().count) { index in
//                    ForEach(0..<healthManager.rides.prefix(5).dropFirst().count) { index in

//                        NavigationLink(value: healthManager.rides[index]) {
                                        NavigationLink(value: previewRideArray[index]) {
                            RideCardPreview(ride: previewRideArray[index]).padding(.horizontal).tag(index)
//                            RideCardPreview(ride: healthManager.rides[index]).padding(.horizontal).tag(index)
                                .foregroundStyle(Color.primary)
                                .containerRelativeFrame(.vertical)
                        }
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: -5) {
                    ForEach(0..<previewRideArray.prefix(5).dropFirst().count) { index in
//                    ForEach(0..<healthManager.rides.prefix(5).dropFirst().count) { index in

                        Circle().foregroundStyle(index == currentPage ? Color.primary : Color.secondary)
                            .frame(height: index == currentPage ? 10 : 7)
                            .padding(7)
                            .onTapGesture {
                            withAnimation {
                                currentPage = index
                            }
                        }

                    }
                }.background {
                    Capsule()
                        .foregroundStyle(.ultraThinMaterial)

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

//                        Spacer()

                        Text(ride.activeEnergyString)
                            .foregroundStyle(.energy)

                    }.bold()
                        .font(.headline)
                        .padding(.vertical)

                    Text(ride.durationString)
                        .fontWeight(.semibold)

                }
                    .padding(.leading)

                RideRouteMap(ride: $ride)
                    .frame(width: 200, height: 150)
                    .padding(.leading)
                    .padding(.trailing, 12)

            }
        }
            .frame(height: 175)

    }
}

#Preview {
    RideCardPreview(ride: PreviewRide)
}
