//
//  TrendView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import SwiftUI
import Charts

@MainActor
struct TrendView: View {

    // MARK: - properties
    @State var statType: TrendType
    @ObservedObject var trendManager: TrendManager = .shared
    @State var timeFrame = TimeFrame.Month

    private var trendData: [TrendItem] {
        switch statType {
        case .HeartRate:
            return trendManager.heartRateTrends
        case .Speed:
            return trendManager.speedTrends
        case .Distance:
            return trendManager.distanceTrends
        case .Energy:
            return trendManager.energyTrends
        }
    }

    private var trendAmount: Double {

        return trendManager.calculateTrendChange(trendType: statType, timeFrame: timeFrame)

    }

    /// message text displayed to inform the user of their trend based on the trend type, timeframe and trend progress
    private var trendMessage: String {

        let upOrDown = trendAmount >= 0 ? "up" : "down"

        let message = "Your average \(statType.rawValue.lowercased()) has been \(upOrDown) \(trendAmount)% over the last \(timeFrame.rawValue.lowercased())"

        return message
    }


    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                HStack {
                    Text(statType.rawValue)
                        .font(.title)
                        .bold()

                    Spacer()
                }

                Picker("Time Frame", selection: $timeFrame.animation(.interactiveSpring)) {
                    ForEach(TimeFrame.allCases) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                    .pickerStyle(.segmented)
                    .padding(.vertical)

                if (trendData.isEmpty) {
                    Text("No ride data found.")
                    
                } else {
                    trendChartView(trendData: Binding(get: { return trendData.filter { $0.date > timeFrame.dateOffset } }, set: { _ in })
                                   , colour: statType.selectionColour)
                }
                

                Divider()
                    .padding(.top)

                HStack {
                    Text(trendMessage)
                    StatDifferenceArrow(color: statType.selectionColour, data: Binding( get: { trendAmount}, set: { _ in }))
                        .padding(.bottom)
                }
                    .padding(.top)

            }
        }

    }
}

@MainActor
struct trendChartView: View {

    @Binding var trendData: [TrendItem]
    @State var colour: Color

    var body: some View {
        Chart(trendData) { item in

            BarMark(
                x: .value(item.date.formatted(), item.date, unit: .day),
                y: .value("BPM", item.value)
            ).interpolationMethod(.catmullRom)
        }
            .foregroundStyle(colour)
    }
}



// MARK: - Previews
#Preview {
    TrendView(statType: .HeartRate)
}
