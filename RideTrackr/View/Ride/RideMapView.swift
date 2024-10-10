//
//  RideMapView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 9/10/2024.
//

import SwiftUI
import MapKit

struct RideMapView: View {

    @State var ride: Ride
    @Binding var selectedZone: HeartRateZone?
    @Binding var selectedOverlay: MapOverlayType
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        Map(interactionModes: .all) {

            if let first = ride.routeData.first {
                Annotation("", coordinate: first.toCLLocationCoordinate2D()) {
                    Circle()
                        .fill(Color.accentColor)
                        .shadow(radius: 5)
                }
            }

            ForEach(0..<ride.routeData.count - 1, id: \.self) { index in
                MapPolyline(coordinates: [ride.routeData[index].toCLLocationCoordinate2D(), ride.routeData[index + 1].toCLLocationCoordinate2D()])
                    .stroke(colorForIntensity(index: index), lineWidth: 5)
            }

            if let last = ride.routeData.last {
                Annotation("", coordinate: last.toCLLocationCoordinate2D()) {
                    Circle()
                        .fill(Color.accentColor)
                        .shadow(radius: 5)
                }
            }


        }
        .mapControlVisibility(.hidden)
            .overlay {
                VStack {
                    HStack(alignment: .top) {
                        MapOverlayPicker(selectedOverlay: $selectedOverlay, selectedZone: $selectedZone)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .labelStyle(.iconOnly)
                                .padding(7)
                                .background(.ultraThickMaterial)
                                .clipShape(Circle())
                            
                        }
                        .bold()
                        .foregroundStyle(.secondary)
                        
                    }
                    .padding()
                    .padding(.top, 50)
                    Spacer()
                }

        }
            .ignoresSafeArea()

    }

    func colorForIntensity(index: Int) -> Color {

        if let selectedZone = selectedZone {
            DispatchQueue.main.async {


                selectedOverlay = .HeartRateZone
            }


            let heartRate = ride.hrSamples[index]
            let zone = HeartRateZoneManager.shared.getZone(heartRate: heartRate.value)
            return zone == selectedZone ? zone.colour : .secondary
        }

        // if the selected overlay is none just return the accent colour
        if selectedOverlay == .None { return selectedOverlay.iconColor }

        if selectedOverlay == .HeartRateZone {
            let heartRate = ride.hrSamples[index]
            let zone = HeartRateZoneManager.shared.getZone(heartRate: heartRate.value)
            return zone.colour
        }

        // get the appropriate sample list
        let selectedSampleList: [StatSample]

        switch selectedOverlay {
        case .HeartRate:
            selectedSampleList = ride.hrSamples
        case .HeartRateZone:
            selectedSampleList = ride.hrSamples
        case .Speed:
            selectedSampleList = ride.speedSamples
        case .Altitude:
            selectedSampleList = ride.altitdueSamples
        case .None:
            selectedSampleList = ride.hrSamples
        }

        // get the min and max values of the list
        let minValue = selectedSampleList.min(by: { $0.value < $1.value })?.value ?? 0
        let maxValue = selectedSampleList.max(by: { $0.value < $1.value })?.value ?? 0

        // get the current sample
        let currentSample = selectedSampleList[index]

        //        let proportion = (currentSample.max - minValue) / (maxValue - minValue)
        let proportion = normalize(currentSample.value, minValue: minValue, maxValue: maxValue, scalingMode: .exponential(base: 2))

        return Color.interpolate(from: selectedOverlay.minColor, to: selectedOverlay.maxColor, proportion: proportion)

    }

    private func normalize(_ value: Double, minValue: Double, maxValue: Double, scalingMode: ScalingMode) -> Double {
        // First normalize to 0-1 range
        let normalizedValue = (value - minValue) / (maxValue - minValue)

        // Then apply scaling function
        switch scalingMode {
        case .linear:
            return normalizedValue

        case .exponential(let base):
            return pow(normalizedValue, base)

        case .logarithmic:
            // Add small epsilon to avoid log(0)
            let epsilon = 0.000001
            return log(normalizedValue + epsilon) / log(1 + epsilon)

        case .sigmoid(let steepness):
            // Center the sigmoid around 0.5
            let centered = normalizedValue - 0.5
            return 1 / (1 + exp(-centered * steepness))

        case .customRange(let min, let max):
            return min + normalizedValue * (max - min)
        }
    }
}

#Preview {
    @Previewable @State var selectedZone: HeartRateZone?
    @Previewable @State var selectedOverlay: MapOverlayType = .None
    RideMapView(ride: PreviewRide, selectedZone: $selectedZone, selectedOverlay: $selectedOverlay)
}
