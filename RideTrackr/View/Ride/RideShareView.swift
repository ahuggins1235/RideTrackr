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
    @State private var ride: Ride
    @State private var isReady = false
    
    init(ride: Ride) {
        _ride = State(initialValue: ride)
    }
    
    var body: some View {
        VStack {
            Text(ride.dateString)
                .font(.title3)
                .bold()
                .padding(.top)
            
            if isReady {
                LargeRidePreview(ride: ride, showDate: false, queryingHealthKit: .constant(false))
            }
        }
        .frame(width: 300, height: 400) // Set a fixed size
        .onAppear {
            // Simulate data loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isReady = true
            }
        }
    }
}

#Preview {
    RideShareView(ride: PreviewRide)
}
