//
//  TrendView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import SwiftUI
import Charts

struct TrendView: View {

    // MARK: - properties
    @State var statType: TrendType
    @EnvironmentObject var trendManager: TrendManager
    @State var timeFrame = TrendTimeFrame.Month

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
                    ForEach(TrendTimeFrame.allCases) { timeFrame in
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

struct trendChartView: View {

    @Binding var trendData: [TrendItem]
    @State var colour: Color

    var body: some View {
        Chart(trendData) { item in

            BarMark(
                x: .value(item.date.formatted(), item.date, unit: .day),
                y: .value("BPM", item.value)
            ).interpolationMethod(.catmullRom)
            
//            PointMark(x: .value(item.date.formatted(), item.date, unit: .day),
//                      y: .value("BPM", item.value))

        }
            .foregroundStyle(colour)
//            .onAppear {
//                for (index, _) in trendData.enumerated() {
//                    withAnimation(.interactiveSpring(response: 0.8,
//                                                     dampingFraction: 0.8,
//                                                     blendDuration: 0.8).delay(Double(index) * 0.05)) {
//                        trendData[index].animate = false
//                    }
//                    //                withAnimation(.easeInOut(duration: 1)) {
//                    //                    trendData[index].animate = true
//                    //                }
//                }
//            }
            
    }
}

enum TrendTimeFrame: String, CaseIterable, Identifiable {
    case SevenDays = "7 Days"
    case Month = "Month"
    case Year = "Year"

    var id: TrendTimeFrame { self }

    var dateOffset: Date {

        let calendar = Calendar.current

        switch self {
        case .SevenDays:
            return calendar.date(byAdding: .day, value: -7, to: Date())!
        case .Month:
            return calendar.date(byAdding: .month, value: -1, to: Date())!
        case .Year:
            return calendar.date(byAdding: .year, value: -1, to: Date())!
        }

    }
}

// MARK: - Previews
#Preview {
    TrendView(statType: .HeartRate).environmentObject(TrendManager())
}
