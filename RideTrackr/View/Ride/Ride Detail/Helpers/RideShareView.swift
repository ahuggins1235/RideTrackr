//
//  RideShareView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/9/2023.
//

import SwiftUI
import MapKit

@MainActor
struct RideShareView: View {
    @State var ride: Ride
    
    var body: some View {
        LazyVStack {
//            Text(ride.dateString)
//                .font(.title3)
//                .bold()
//                .padding(.vertical)
//            
//
            
            LargeRidePreview(ride: $ride, showDate: true, queryingHealthKit: .constant(false))
                .padding()
//                .frame(height: 250)
        }
        .background(.clear)
//        .border(.red)
//        .frame(height: 500) // Set a fixed size
    }
}
#Preview {
    RideShareView(ride: PreviewRide)
}
