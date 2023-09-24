//
//  RideShareView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/9/2023.
//

import SwiftUI

struct RideShareView: View {
    
    @State var ride: Ride
    
    var body: some View {
        
        VStack {
            
            Text(ride.dateString)
                .font(.title3)
                .bold()
                .padding(.top)
            
            // ride preview
            LargeRidePreview(ride: $ride, showDate: false, queryingHealthKit: .constant(false))
                
                .padding()
                
        }
        .frame(height: 200)
        
    }
}

#Preview {
    RideShareView(ride: PreviewRide)
}
