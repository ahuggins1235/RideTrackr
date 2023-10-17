//
//  RecentRideView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct LargeRidePreview: View {

    // MARK: - Properties
    @EnvironmentObject var trendManager: TrendManager
//    @EnvironmentObject var manager: HealthManager
    @Binding var ride: Ride
    @State var showDate = true
    @Binding var queryingHealthKit: Bool

    var body: some View {

        ZStack {
            // MARK: - Background
            RoundedRectangle(cornerRadius: 15)
                .fill(.cardBackground)
                .shadow(radius: 4, x: 2, y: 2)

            // MARK: - Body
            ZStack {
                
            
                VStack(alignment: .leading) {

                    if showDate {
                        Text(ride.dateString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 8), count: 2)) {
                        RideStatCardView(color: .heartRate, title: "Avg. Heart Rate", data: Binding(get: { ride.heartRateString }, set: { _ in }), differenceFromAverage: Binding( get: { ((ride.heartRate - trendManager.currentAverageHeartRate) / ride.heartRate) * 100 }, set: {_ in} ))
                        RideStatCardView(color: .speed, title: "Avg. Speed", data: Binding(get: { ride.speedString }, set: { _ in }), differenceFromAverage: Binding(get: { ((ride.speed - trendManager.currentAverageSpeed) / trendManager.currentAverageSpeed) * 100 }, set: { _ in }))
                        RideStatCardView(color: .distance, title: "Distance", data: Binding(get: { ride.distanceString }, set: { _ in }), differenceFromAverage: Binding(get: { ((ride.distance - trendManager.currentAverageDistance) / trendManager.currentAverageDistance) * 100 }, set: { _ in }))
                        RideStatCardView(color: .energy, title: "Active Energy", data: Binding(get: { ride.activeEnergyString }, set: { _ in }), differenceFromAverage: Binding(get: { ((ride.activeEnergy - trendManager.currentAverageEnergy) / trendManager.currentAverageEnergy) * 100 }, set: { _ in }))
//                        RideStatCardView(color: .speed, title: "Avg. Speed", data: Binding(get: { ride.speedString }, set: { _ in }), differenceFromAverage: ((ride.speed - trendManager.currentAverageSpeed) / trendManager.currentAverageSpeed) * 100)
//                        RideStatCardView(color: .distance, title: "Distance", data: Binding(get: { ride.distanceString }, set: { _ in }), differenceFromAverage: ((ride.distance - trendManager.currentAverageDistance) / trendManager.currentAverageDistance) * 100)
//                        RideStatCardView(color: .energy, title: "Active Energy", data: Binding(get: { ride.activeEnergyString }, set: { _ in }), differenceFromAverage: ((ride.activeEnergy - trendManager.currentAverageEnergy) / trendManager.currentAverageEnergy) * 100)
                        RideStatCardView(color: .duration, title: "Duration", data: Binding(get: { ride.durationString }, set: { _ in }), differenceFromAverage: Binding(get: {0.0}, set: { _ in} ), showDifference: false)
                        RideStatCardView(color: .altitude, title: "Altitude Gained", data: Binding(get: { ride.alitudeString }, set: { _ in }), differenceFromAverage: Binding(get: {0.0}, set: { _ in} ), showDifference: false)

                    }
                        .padding(10)

                    Spacer()

                }
                .overlay {
                    ZStack {
                        if queryingHealthKit {
                            
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                            
                            ProgressView("Loading")
                                .ignoresSafeArea()
                            
                            
                            
                        }
                    }
                }
            }
        }
    }
}


//MARK: - Previews
#Preview {
    @State var previewRide = PreviewRide
    return LargeRidePreview(ride: $previewRide, queryingHealthKit: .constant(false)).environmentObject(TrendManager())
}

#Preview {
    StatDifferenceArrow(color: .blue, data: .constant(-11))
}

// MARK: - Ride stat card view
struct RideStatCardView: View {

    @State var color: Color
    @State var title: String
    @Binding var data: String
    @Binding var differenceFromAverage: Double

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
                    Text(data).lineLimit(1, reservesSpace: true)

                    Spacer()

                    if showDifference {

                        Text(String(format: "%.1f", differenceFromAverage) + "%").lineLimit(1, reservesSpace: true)
                        StatDifferenceArrow(color: color, data: $differenceFromAverage).padding(.horizontal, -5)
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
    @Binding var data: Double

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

