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
            Circle()
                .frame(width: 50)
//            Map(interactionModes: .zoom) {
//                MapPolyline(coordinates: ride.routeData.map { $0.coordinate })
//                    .stroke(.blue, lineWidth: 5)
//            }
//                .frame(width: 100,height: 100)
//                .clipShape(Circle())
            
            VStack {
                
                // small details
                HStack {
                    
                    Text(ride.activeEnergyString)
//                        .foregroundStyle(.orange)
                        
                    Text(ride.durationString)
//                        .foregroundStyle(.cyan)
                    
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
//                        .foregroundStyle(.green)
                    
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
