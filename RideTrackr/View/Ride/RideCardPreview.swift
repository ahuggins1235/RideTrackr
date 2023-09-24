//
//  RideCardPreview.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 23/9/2023.
//

import SwiftUI

struct RideCardPreview: View {
    
    @State var ride: Ride
    
    var body: some View {
        
        ZStack {
            
            Color.cardBackground
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(radius: 4, x: 2, y: 2)
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(ride.dateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(ride.distanceString)
                        .foregroundStyle(.green)
                    Spacer()
                    Text(ride.activeEnergyString)
                        .foregroundStyle(.orange)
                }.bold()
                    .font(.title3)
                
                Text(ride.durationString)
                    .fontWeight(.semibold)
                
            }
            .padding()
        }
    }
}

#Preview {
    RideCardPreview(ride: PreviewRide)
}
