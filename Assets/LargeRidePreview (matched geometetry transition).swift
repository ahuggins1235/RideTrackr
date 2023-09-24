//
//  RecentRideView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct LargeRidePreview: View {

    // MARK: - Properties
    @EnvironmentObject var manager: HealthManager
    @Binding var ride: Ride
    @State var showDate = true

    var body: some View {
        
        ZStack {
            // MARK: - Background
            Color(uiColor: .systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 4, x: 2, y: 2)
            
            // MARK: - Body
            VStack(alignment: .leading) {
                
                if showDate {
                    Text(ride.dateString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 8), count: 2)) {
                    RideStatCardView(color: .red, title: "Avg. Heart Rate", data: ride.heartRateString, differenceFromAverage: 10)
                    RideStatCardView(color: .blue, title: "Avg. Speed", data: ride.speedString, differenceFromAverage: 11)
                    RideStatCardView(color: .green, title: "Distance", data: ride.distanceString, differenceFromAverage: -5)
                    RideStatCardView(color: .orange, title: "Active Energy", data: ride.activeEnergyString, differenceFromAverage: -11)
                    RideStatCardView(color: .cyan, title: "Duration", data: ride.durationString, showDifference: false)
                    RideStatCardView(color: .mint, title: "Altitude Gained", data: ride.alitudeString, showDifference: false)
                    
                }
                .padding(10)
                
                Spacer()
                
            }
        }
    }
}


//MARK: - Previews
#Preview {
    @State var previewRide = PreviewRide
    return LargeRidePreview(ride: $previewRide).environmentObject(HealthManager())
}

#Preview {
    StatDifferenceArrow(color: .blue, data: -11)
}

// MARK: - Ride stat card view
struct RideStatCardView: View {
    
    @State var color: Color
    @State var title: String
    @State var data: String
    @State var differenceFromAverage: Double = 0
    @State var showDifference: Bool = true
    
    var body: some View {
        
        ZStack {
            Color(uiColor: .systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 4, x: 2, y: 2)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                
                HStack {
                    Text(data)
                    
                    Spacer()
                    
                    if showDifference {
                        
                        Text(String(format: "%.1f", differenceFromAverage) + "%")
                        StatDifferenceArrow(color: color, data: differenceFromAverage).padding(.horizontal, -5)
                    }
                }
                .foregroundStyle(color)
                .font(.subheadline)
                .bold()
                
            }
            .padding()
            
        }
        
    }
}

// MARK: - Stat difference Arrow 
struct StatDifferenceArrow: View {
    
    @State var color: Color
    @State var data: Double
    
    var body: some View {
        
        ZStack {
            
            switch data {
            case let x where x > 10:
                
                ZStack {
                    Image(systemName: "arrowtriangle.up.fill").offset(x: 0, y: -4.5)
                    Image(systemName: "arrowtriangle.up.fill").offset(x: 0, y: 4.5)
                }
                
            case 1...10:
                
                Image(systemName: "arrowtriangle.up.fill")
                
            case -10..<0:
                
                Image(systemName: "arrowtriangle.down.fill")
                
            default:
                
                ZStack {
                    Image(systemName: "arrowtriangle.down.fill").offset(x: 0, y: -4.5)
                    Image(systemName: "arrowtriangle.down.fill").offset(x: 0, y: 4.5)
                }
                
            }
        }.foregroundStyle(color)
        
    }
}

