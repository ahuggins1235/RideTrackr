//
//  RideRowView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import SwiftUI
import MapKit
import PolyKit

@MainActor
struct RideRowView: View {

    //MARK:  - properties
    @State var ride: Ride

    // MARK: - body
    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 15)
                .fill(.cardBackground)
                .padding(.horizontal)

            HStack {

                // Map
                if let firstLocation = ride.routeData.first {
                    SmallMapPreviewView(location: CLLocationCoordinate2D(latitude: firstLocation.latitude, longitude: firstLocation.longitude), route: ride.routeData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }))
                        .clipShape(Circle())
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .frame(width: 100, height: 100)
                        .shadow(radius: 3)


                } else {

                    Circle()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
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
                    HStack(alignment: .top) {

                        Text(ride.activeEnergyString)
                        Text(ride.durationString)
                        Spacer()
                        
                        if let effortScore = ride.effortScore {
                            if effortScore > 0 {
                                
                                ZStack {
                                    Text(String(Int(effortScore)))
                                        .font(.footnote)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(7)
                                        .background {

                                        Polygon(count: Int(effortScore) + 3, relativeCornerRadius: 0.2)
                                            .fill(.effort.gradient)
                                            .stroke(Color.white, lineWidth: 3)
                                            .shadow(color: .purple, radius: 30)
                                    }
                                }
                                    .padding(.trailing)
                                    .padding(.top, -7)
                                    .padding(.bottom, -15)
                            }
                        }
                    }
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .fontWeight(.semibold)

                    // large details
                    HStack {

                        Text(ride.distanceString)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)

                        Text(ride.shortDateString)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                        .foregroundStyle(.accent)
                        .padding([.trailing, .top, .bottom])
                }
            }
                .padding(.vertical, 3)
                .padding(.horizontal)
        }
    }
}

// MARK: - previews
#Preview {
    RideRowView(ride: PreviewRide)
}
