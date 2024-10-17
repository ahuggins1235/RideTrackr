//
//  RideGraphsView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 10/10/2024.
//

import SwiftUI
import Charts

struct RideGraphsView: View {
    
    @Binding var ride: Ride
    @AppStorage("distanceUnit") private var distanceUnit: DistanceUnit = .Metric
    
    var body: some View {
        
        VStack {
            
            if ride.hrSamples.count != 0 {
                
                ChartCardView(
                    title: "Heart Rate",
                    rightText: "AVG",
                    color: .heartRate,
                    samples: $ride.hrSamples,
                    unit: .constant("BPM"),
                    average: .constant(ride.heartRate.rounded()),
                    icon: "heart.fill"
                ).padding(.bottom)
                
            }
            
            if ride.speedSamples.count != 0 {
                
                ChartCardView(
                    title: "Speed",
                    rightText: "AVG",
                    color: .speed,
                    samples: Binding(get: { ride.speedSamples.map({ stat in StatSample(date: stat.date, value: stat.value * distanceUnit.distanceConversion) }) }),
                    unit: Binding(get: { "\(distanceUnit.speedAbr)" }),
                    average: Binding(get: { (ride.speed * distanceUnit.distanceConversion).rounded() }),
                    icon: "speedometer"
                ).padding(.bottom)
                
            }
            
            if ride.altitdueSamples.count != 0 {
                
                ChartCardView(
                    title: "Altitude",
                    rightText: "GAIN",
                    color: .altitude,
                    samples: Binding(get: { ride.altitdueSamples.map({ stat in StatSample(date: stat.date, value: stat.value * distanceUnit.smallDistanceConversion) }) }),
                    unit: Binding(get: { "\(distanceUnit.smallDistanceAbr)" }),
                    average: Binding(get: { (ride.altitudeGained * distanceUnit.smallDistanceConversion).rounded() }),
                    icon: "mountain.2"
                ).padding(.bottom)
            }
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .move(edge: .bottom))
        ))
        
    }
}

#Preview {
    @Previewable @State var ride: Ride = PreviewRide
    RideGraphsView(ride: $ride)
}

// MARK: - ChartCard
@MainActor
struct ChartCardView: View {
    
    @State var title: String
    @State var rightText: String
    @State var color: Color
    @Binding var samples: [StatSample]
    @Binding var unit: String
    @Binding var average: Double
    var icon: String?
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                    
                    
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .foregroundStyle(color)
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, -10)
            
            
            // chart
            Chart(samples) { sample in
                
                LineMark(
                    x: .value(sample.date.formatted(), sample.date, unit: .second),
                    y: .value(unit, sample.value)
                )
                .foregroundStyle(color.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value(sample.date.formatted(), sample.date, unit: .second),
                    y: .value(unit, sample.value)
                )
                .foregroundStyle(color.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)
            }
            
            .padding()
            
            // min max caption
            HStack {
                Text("MIN: \((samples.min(by: { $0.value < $1.value })?.value ?? 0).rounded().formatted()) \(unit)")
                Text("MAX: \((samples.max(by: { $0.value < $1.value })?.value ?? 0).rounded().formatted()) \(unit)")
                Spacer()
                Text("\(rightText): \(average.formatted()) \(unit)")
            }
            .font(.caption)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .foregroundStyle(color)
            .bold()
            
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.horizontal)
        .scrollTransition(.animated(.interactiveSpring(response: 0.8, dampingFraction: 0.75, blendDuration: 0.8)).threshold(.visible(0.3))) { content, phase in
            
            content
                .opacity(phase.isIdentity ? 1.0 : 0.3)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.3)
        }
    }
}

struct AnimationModifier: ViewModifier {
    let positionOffset: Double
    let height = UIScreen.main.bounds.height
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let position = geometry.frame(in: CoordinateSpace.global).midY
            ZStack {
                Color.clear
                if height >= (position + positionOffset) {
                    content
                }
            }
        }
    }
}
