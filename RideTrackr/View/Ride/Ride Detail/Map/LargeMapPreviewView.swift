//
//  LargeMapPreviewView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 5/7/2024.
//

import SwiftUI
import MapKit

struct LargeMapPreviewView: View {
    var routeData: [PersistentLocation]
    var temperatureString: String?
    var effortScore: Double?
    @Binding var selectedOverlay: MapOverlayType
    @State var ride: Ride
    @Binding var selectedZone: HeartRateZone?
    @Binding var keyHigh: Double?
    @Binding var keyLow: Double?
    @Binding var colHigh: Color?
    @Binding var colLow: Color?


    var body: some View {

        ZStack {

            Rectangle()
                .fill(.secondary)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .blur(radius: 15)
                .frame(height: 300)

            if let _ = routeData.first {
                
                // MARK: - Map
                Map(interactionModes: [.pan, .zoom]) {
                    if let first = routeData.first {
                        Annotation("", coordinate: first.toCLLocationCoordinate2D()) {
                            Circle()
                                .fill(Color.accentColor)
                                .shadow(radius: 5)
                        }
                    }

                    ForEach(0..<routeData.count - 1, id: \.self) { index in
                        MapPolyline(coordinates: [routeData[index].toCLLocationCoordinate2D(), routeData[index + 1].toCLLocationCoordinate2D()])
                            .stroke(colorForIntensity(index: index), lineWidth: 5)
                    }

                    if let last = routeData.last {
                        Annotation("", coordinate: last.toCLLocationCoordinate2D()) {
                            Circle()
                                .fill(Color.accentColor)
                                .shadow(radius: 5)
                        }
                    }
                }
                    .animation(.easeInOut(duration: 0.5), value: routeData)
                    .frame(height: 300)
                    .mapStyle(.standard(elevation: .realistic))
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                // MARK: - Overlay
                    .overlay {
                        VStack {
                            HStack {
                                MapOverlayPicker(selectedOverlay: $selectedOverlay, selectedZone: $selectedZone, keyHigh: $keyHigh, keyLow: $keyLow, colHigh: $colHigh, colLow: $colLow)
                                
                                
                                Spacer()
                                
                                if let effortScore = effortScore {
                                    if effortScore > 0 {
                                        EffortScoreView(score: effortScore)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .frame(height: 50)
                            .padding()
                            
                            if let temperature = temperatureString {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        TemperatureView(temperature: temperature, humidity: ride.humidity)
                                            .padding()
                                    }
                                }
                            }
                        }
                    }

                // MARK: - Temperature
                
            } else {
                HStack {
                    Spacer()
                    Text("No route data found")
                        .bold()
                        .padding(.top)
                    Spacer()
                }
            }
        }
        .onChange(of: selectedOverlay) { _, _ in
            
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
            
            keyLow = minValue
            keyHigh = maxValue
            colLow = selectedOverlay.minColor
            colHigh = selectedOverlay.maxColor
            
        }
    }

    // MARK: - Functions
    func colorForIntensity(index: Int) -> Color {
        
        if let selectedZone = selectedZone {
            DispatchQueue.main.async {
                selectedOverlay = .HeartRateZone
            }

            let heartRate = ride.hrSamples[index]
            let zone = HeartRateZoneManager.shared.getZone(heartRate: heartRate.value)
            return zone == selectedZone ? zone.colour : .gray
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
    LargeMapPreviewView(
        routeData: PreviewRide.routeData,
        temperatureString: PreviewRide.temperatureString,
        effortScore: 0,
        selectedOverlay: $selectedOverlay,
        ride: PreviewRide,
        selectedZone: $selectedZone,
        keyHigh: .constant(25),
        keyLow: .constant(15),
        colHigh: .constant(.red),
        colLow: .constant(.blue)
    )
}

enum ScalingMode {
    case linear // Original scaling
    case exponential(base: Double) // e.g., 2 for squared, 3 for cubed
    case logarithmic
    case sigmoid(steepness: Double) // Controls how sharp the S-curve is
    case customRange(min: Double, max: Double) // Maps to a specific range
}
