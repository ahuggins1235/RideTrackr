//
//  RideRowView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import SwiftUI
import MapKit

@MainActor
struct RideRowView: View {

    //MARK:  - properties
    @State var ride: Ride


    // MARK: - body
    var body: some View {

        HStack {

            // Map
            if let firstLocation = ride.routeData.first {
                MapSnapshotView(location: CLLocationCoordinate2D(latitude: firstLocation.latitude, longitude: firstLocation.longitude), route: ride.routeData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }))
                .clipShape(Circle())
                    .padding(5)
                    .frame(width: 100, height: 100)
                    .shadow(radius: 3)
            } else {

                Circle()
                    .padding(5)
                    .frame(width: 100)
                    .shadow(radius: 3)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay (
                    Text("No route data found")
                        .multilineTextAlignment(.center)
                        .bold()
                        .font(.caption)
                        .padding()
                )
            }

            VStack {

                // small details
                HStack {

                    Text(ride.activeEnergyString)

                    Text(ride.durationString)

                    Spacer()

                }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .fontWeight(.semibold)

                // large details
                HStack {

                    Text(ride.distanceString)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(ride.shortDateString)
                        .font(.headline)


                }
                    .foregroundStyle(.accent)
                    .padding([.trailing, .top, .bottom])
            }
        }
    }
}

// MARK: - previews
#Preview {
    RideRowView(ride: PreviewRideNoRouteData)
}
