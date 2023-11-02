//
//  RideRowView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import SwiftUI
import MapKit

struct RideRowView: View {
    
    //MARK:  - properties
    @State var ride: Ride
    
    
    // MARK: - body
    var body: some View {
    
        HStack {
            
            // Map
//            Circle()
//                .frame(width: 50)
            MapSnapshotView(location: ride.routeData.first!.coordinate, route: ride.routeData.map({ $0.coordinate }))
//                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .clipShape(Circle())
                .padding(5)
                .frame(width: 100, height: 100)
                .shadow(radius: 3)
            
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
    RideRowView(ride: PreviewRide)
}
