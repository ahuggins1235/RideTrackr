//
//  TrendPreviewView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/7/2024.
//

import SwiftUI

struct TrendPreviewView: View {

    @ObservedObject var trendManager: TrendManager = .shared
    @ObservedObject var navigationManager: NavigationManager = .shared
    @ObservedObject var settingsManager: SettingsManager = .shared

    var body: some View {

        VStack(alignment: .leading, spacing: 15) {

            TimeFramePicker(timeFrame: $trendManager.timeFrame)
                .zIndex(100)
                .unredacted()


            LazyVGrid(columns: [.init(.flexible()), .init(.flexible()) ]) {

                TrendCardView(
                    bgColor: .heartRate,
                    title: "Average Heart Rate",
                    icon: "heart.fill",
                    data: Binding(get: { "\(String(format: "%.0f", trendManager.currentAverageHeartRate)) BMP" })
                )
//                    .onTapGesture {
//                    navigationManager.selectedTrendsTab = .HeartRate
//                    navigationManager.selectedTab = .Trends
//                }

                TrendCardView(
                    bgColor: .speed,
                    title: "Average Speed",
                    icon: "speedometer",
                    data: Binding(get: { "\(round((trendManager.currentAverageSpeed * settingsManager.distanceUnit.distanceConversion) * 10) / 10) \(settingsManager.distanceUnit.speedAbr)" })
                )
//                    .onTapGesture {
//                    navigationManager.selectedTrendsTab = .Speed
//                    navigationManager.selectedTab = .Trends
//                }

                TrendCardView(
                    bgColor: .distance,
                    title: "Average Distance",
                    icon: "figure.outdoor.cycle",
                    data: Binding (get: { "\(round((trendManager.currentAverageDistance * settingsManager.distanceUnit.distanceConversion) * 10) / 10) \(settingsManager.distanceUnit.distAbr)" })
                )
//                    .onTapGesture {
//                    navigationManager.selectedTrendsTab = .Distance
//                    navigationManager.selectedTab = .Trends
//                }

                TrendCardView(
                    bgColor: .energy,
                    title: "Average Active Energy",
                    icon: "flame.fill",
                    data: Binding (get: { "\(round((trendManager.currentAverageEnergy * settingsManager.energyUnit.conversionValue) * 10) / 10) \(settingsManager.energyUnit.abr)" })
                )
//                    .onTapGesture {
//                    navigationManager.selectedTrendsTab = .Energy
//                    navigationManager.selectedTab = .Trends
//                }
            }
        }
    }
}

#Preview {
    TrendPreviewView(trendManager: PreviewTrendManager())
}

struct TimeFramePicker: View {

    @Binding var timeFrame: TimeFrame
    @State var expanded: Bool = false

    var body: some View {

        HStack {

            Text("Last \(timeFrame.rawValue)")

            Label("Drop Down Arrow", systemImage: "chevron.down")
                .rotationEffect(Angle(degrees: expanded ? -180 : 0))
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)

        }
            .bold()
            .frame(alignment: .leading)
            .padding(9)
            .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
            .sensoryFeedback(.impact, trigger: expanded)
            .overlay(alignment: .leading) {
            if expanded {

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(TimeFrame.allCases) { timeFrame in
                        VStack {
                            Text(timeFrame.rawValue)
                                .onTapGesture {
                                withAnimation {
                                    self.timeFrame = timeFrame
                                    expanded.toggle()
                                }
                            }
                            Divider()
                        }
                    }
                }
                    .frame(width: 100, alignment: .leading)
                    .bold()
                    .padding(10)
                    .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThickMaterial)
                }
                    .offset(y: 100)
                    .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
            .font(.title3)
    }
}
