//
//  RideShareView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/9/2023.
//

import SwiftUI
import MapKit

struct RideShareView: View {
    
    @EnvironmentObject var trendManager: TrendManager
    
    @State var ride: Ride
    
    var body: some View {
        
        VStack {
            
            Text(ride.dateString)
                .font(.title3)
                .bold()
                .padding(.top)
            
//            MapSnapshotView(location: ride.routeData.first!.coordinate, route: ride.routeData.map({ $0.coordinate }))
            
            // ride preview
//            LargeRidePreview(ride: $ride, showDate: false, queryingHealthKit: .constant(false)).environmentObject(trendManager)
            

                
        }
        .frame(height: 200)
        
    }
}

#Preview {
    RideShareView(ride: PreviewRide).environmentObject(TrendManager())
}
