//
//  RecentRideView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct LargeRidePreview: View {

    // MARK: - Properties
    @ObservedObject var trendManager: TrendManager = .shared
    @State var ride: Ride
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
                        RideStatCardView(color: .heartRate, title: "Avg. Heart Rate", displayString: Binding(get: { ride.heartRateString }), trendAverage: Binding(get: { trendManager.currentAverageHeartRate }), data: $ride.heartRate, queryingHealthKit: queryingHealthKit, showDifference: !queryingHealthKit)
                        RideStatCardView(color: .speed, title: "Avg. Speed", displayString: Binding(get: { ride.speedString }), trendAverage: Binding(get: { trendManager.currentAverageSpeed }), data: $ride.speed, queryingHealthKit: queryingHealthKit, showDifference: !queryingHealthKit)
                        RideStatCardView(color: .distance, title: "Distance", displayString: Binding(get: { ride.distanceString }), trendAverage: Binding(get: { trendManager.currentAverageDistance }), data: $ride.distance, queryingHealthKit: queryingHealthKit, showDifference: !queryingHealthKit)
                        RideStatCardView(color: .energy, title: "Active Energy", displayString: Binding(get: { ride.activeEnergyString }), trendAverage: Binding(get: { trendManager.currentAverageEnergy }), data: $ride.activeEnergy, queryingHealthKit: queryingHealthKit, showDifference: !queryingHealthKit)
                        RideStatCardView(color: .duration, title: "Duration", displayString: Binding(get: { ride.durationString }), trendAverage: Binding(get: { 0.0 }), data: Binding(get: { 0.0 }), queryingHealthKit: queryingHealthKit, showDifference: false)
                        RideStatCardView(color: .altitude, title: "Altitude Gained", displayString: Binding(get: { ride.alitudeString }), trendAverage: Binding(get: { 0.0 }), data: Binding(get: { 0.0 }), queryingHealthKit: queryingHealthKit, showDifference: false)

                    }
                        .padding(10)
                    Spacer()
                }
            }
        }
    }
}


//MARK: - Previews
#Preview {
    @Previewable @State var previewRide = PreviewRide
    return LargeRidePreview(ride: previewRide, queryingHealthKit: .constant(false)).environmentObject(TrendManager())
}

#Preview {
    StatDifferenceArrow(color: .blue, data: .constant(-11))
}

// MARK: - Ride stat card view

struct RideStatCardView: View {

    @State var color: Color
    @State var title: String
    @Binding var displayString: String
    @Binding var trendAverage: Double
    @Binding var data: Double
    @State var queryingHealthKit: Bool

    @State private var animateArrow = false

    @State var showDifference: Bool = true

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.ultraThinMaterial)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)

                HStack {
                    Text(displayString).lineLimit(1)

                    Spacer()

                    if showDifference && !trendAverage.isNaN {

                        Text(String(format: "%.1f", GetDifferenceFromAverage(trendAverage, data)) + "%").lineLimit(1, reservesSpace: true)

                        StatDifferenceArrow(color: color,
                            data: Binding(get: { GetDifferenceFromAverage(trendAverage, data) })
                        )
                            .opacity(animateArrow ? 1 : 0)
                            .offset(y: animateArrow ? 0 : 10)
                            .padding(.horizontal, -7)
                    }
                }
                    .foregroundStyle(color)
                    .font(.footnote)
                    .bold()
                    .onAppear {

                    withAnimation(.easeInOut(duration: 0.8)) {
                        animateArrow = true
                    }
                }
            }.padding()
        }
    }


    /// Calculates the difference between two numbers expressed as a percentage of the first number.
    /// - Parameters:
    ///   - num1: The first number
    ///   - num2: The second number
    /// - Returns: The difference between the two numbers expressed as a percentage of the first number.
    func GetDifferenceFromAverage(_ num1: Double, _ num2: Double) -> Double {
        let difference = num2 - num1
        let percentageDifference = (difference / num1) * 100
        return percentageDifference
    }
}

// MARK: - Stat difference Arrow
@MainActor
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

