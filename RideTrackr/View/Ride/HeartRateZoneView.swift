//
//  HeartRateZoneView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 8/10/2024.
//

import SwiftUI

struct HeartRateZoneView: View {

    public let hrSamples: [StatSample]
    public let rideDuration: TimeInterval

    private var heartRateZones: [HeartRateZone: TimeInterval] {
        return HeartRateZoneManager.shared.calculateZoneDurations(samples: hrSamples)
    }

    @State var showInfoSheet: Bool = false
    @Binding var selectedZone: HeartRateZone?

    var body: some View {


        VStack {

            HStack {
                Text("Training Zones")
                    .font(.headline)
                    .bold()
                Spacer()

                Button {
                    showInfoSheet.toggle()

                } label: {
                    Label("Heart rate zone information", systemImage: "info.circle")
                        .labelStyle(.iconOnly)

                }
                    .foregroundStyle(.secondary)
            }
                .padding(.bottom, 5)

            ForEach(HeartRateZone.allCases) { zone in

                let duration = heartRateZones[zone]
                let percentage = (duration! / rideDuration) * 100.0
                HStack {

                    Text(String(zone.rawValue))
                    GeometryReader { geometry in
                        HStack {
                            Capsule()
                                .frame(width: (geometry.size.width * CGFloat(percentage / 100.0)), height: 20)
                            Text("\(Int(percentage))%")
                        }
                    }

                    Spacer()

                    Text(String(HeartRateZoneManager.formatDuration(duration!)))

                }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedZone = selectedZone == zone ? nil : zone
                    }
                    .foregroundStyle(selectedZone == zone ? zone.colour : selectedZone == nil ? zone.colour : .secondary)
                    .bold()
            }
        }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding()
            .sheet(isPresented: $showInfoSheet) {

            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {

                        Text("Heart Rate Training Zones")
                            .bold()
                            .font(.largeTitle)

                        Spacer()
                        Button {
                            showInfoSheet.toggle()
                        } label: {
                            Label("Close", systemImage: "xmark").labelStyle(.iconOnly)

                                .padding(6)
                                .background(.ultraThickMaterial)
                                .clipShape(Circle())

                        }
                            .bold()
                            .foregroundStyle(.secondary)
                    }


                    Text("Heart rate training zones show your intensity level at different points in your workout. The zones are calculated using your maximim heart rate (MHR) and your average resting heart rate.")
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 10) {

                        ForEach(HeartRateZone.allCases) { zone in
                            zone.longDescription
                                .foregroundStyle(zone.colour)
                        }
                    }
                }
                    .presentationDetents([.height(575)])
                    .presentationDragIndicator(.visible)
                    .padding()
            }
        }
            .onChange(of: showInfoSheet) { _, _ in
            print(showInfoSheet)
        }
    }
}



#Preview {
    @Previewable @State var selectedZone: HeartRateZone?
    
    HeartRateZoneView(hrSamples: [
        StatSample(date: Date(), value: 90.0),
        StatSample(date: Date().addingTimeInterval(60), value: 95.0),
        StatSample(date: Date().addingTimeInterval(120), value: 100.0),
        StatSample(date: Date().addingTimeInterval(180), value: 92.0),
        StatSample(date: Date().addingTimeInterval(240), value: 96.0),
        StatSample(date: Date().addingTimeInterval(300), value: 102.0),
        StatSample(date: Date().addingTimeInterval(360), value: 105.0),
        StatSample(date: Date().addingTimeInterval(420), value: 94.0)
    ], rideDuration: 1000, selectedZone: $selectedZone)
}
