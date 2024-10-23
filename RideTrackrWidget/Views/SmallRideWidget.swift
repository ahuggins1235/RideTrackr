//
//  SmallRideWidget.swift
//  RideTrackrWidgetExtension
//
//  Created by Andrew Huggins on 12/10/2024.
//

import SwiftUI

struct SmallRideWidget: View {
    
    var entry: RideEntry
    
    var body: some View {
        VStack {
 
            HStack(alignment: .bottom) {
                Text(entry.ride.shortDateString)
                    Spacer()
                    Image(systemName: "bicycle")
                }
                .padding()
                .contentShape(Rectangle())
                .background(Color.accent.gradient)
                .foregroundStyle(.white)
                .font(.footnote)
                .fontWeight(.heavy)
            
            
            Spacer()
            
            Grid(alignment:.leading) {
                GridRow {
                    Image(systemName: "heart.fill")
                        .gridColumnAlignment(.center)
                    Text(entry.ride.heartRateString)
                }.foregroundStyle(.heartRate)
                GridRow {
                    Image(systemName: "speedometer")
                    Text(entry.ride.speedString)
                }.foregroundStyle(.speed)
                GridRow {
                    Image(systemName: "figure.outdoor.cycle")
                    Text(entry.ride.distanceString)
                }.foregroundStyle(.distance)
                GridRow {
                    Image(systemName: "flame.fill")
                    Text(entry.ride.activeEnergyString)
                }.foregroundStyle(.energy)
                Spacer()
            }
            .foregroundStyle(.white)
            .bold()
            
            Spacer()
        }
        .widgetURL(URL(string: "ridetrackr://ride/\(entry.ride.rideDate)"))
    }
}

#Preview {
    SmallRideWidget(entry: RideEntry(date: .now, ride: PreviewRide))
}
