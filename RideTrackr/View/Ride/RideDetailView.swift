//
//  RideDetailView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/7/2023.
//

import SwiftUI
import Charts
import MapKit

struct RideDetailView: View {

    // MARK: - Properties
    @StateObject private var imageGenerator = ImageGenerator()
    @State var ride: Ride = Ride()
    @Environment(\.displayScale) private var displayScale: CGFloat
    @ObservedObject var trendManager: TrendManager = .shared
    @AppStorage("distanceUnit") private var distanceUnit: DistanceUnit = .Metric
    @State private var isGeneratingImage = true

    // MARK: - Body
    var body: some View {

        ZStack {
            ScrollView {

                VStack(alignment: .leading) {

                    // map
                    LargeMapPreviewView(routeData: ride.routeData, temperatureString: ride.temperatureString, effortScore: ride.effortScore)
                        .padding()
                    

                    // ride preview
                    LargeRidePreview(ride: ride, showDate: false, queryingHealthKit: .constant(false))
                        .padding()

                    if ride.hrSamples.count != 0 {

                        ChartCardView(samples: $ride.hrSamples,
                            title: "Heart Rate",
                            unit: .constant("BPM"),
                            color: .heartRate,
                            average: .constant(ride.heartRate.rounded()),
                            rightText: "AVG"
                        ).padding(.bottom)

                    }

                    if ride.speedSamples.count != 0 {

                        ChartCardView(samples: Binding(get: { ride.speedSamples.map({ stat in StatSample(date: stat.date, min: stat.min * distanceUnit.distanceConversion, max: stat.max * distanceUnit.distanceConversion) }) }),
                            title: "Speed",
                            unit: Binding(get: { "\(distanceUnit.speedAbr)" }),
                            color: .speed,
                            average: Binding(get: { (ride.speed * distanceUnit.distanceConversion).rounded() }),
                            rightText: "AVG"
                        ).padding(.bottom)

                    }

                    if ride.altitdueSamples.count != 0 {

                        ChartCardView(samples: Binding(get: { ride.altitdueSamples.map({ stat in StatSample(date: stat.date, min: stat.min * distanceUnit.smallDistanceConversion, max: stat.max * distanceUnit.smallDistanceConversion) }) }),
                            title: "Altitude",
                            unit: Binding(get: { "\(distanceUnit.smallDistanceAbr)" }),
                            color: .altitude,
                            average: Binding(get: { (ride.altitudeGained * distanceUnit.smallDistanceConversion).rounded() }),
                            rightText: "GAIN"
                        ).padding(.bottom)
                    }
                }
            }
        }

            .navigationTitle(ride.dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            ToolbarItem {
                Group {
                    if isGeneratingImage {
                        ProgressView()
                    }
                    if let generatedImage = imageGenerator.generatedImage {
                        ShareLink(item: generatedImage, preview: SharePreview("", image: generatedImage))
                    }
                }
            }
        } .onAppear {
            Task {
                await imageGenerator.generateSharingImage(ride: ride, displayScale: displayScale)

                isGeneratingImage = false

            }
        }
    }
}

// MARK: - ChartCard
@MainActor
struct ChartCardView: View {

    @Binding var samples: [StatSample]
    @State var title: String
    @Binding var unit: String
    @State var color: Color
    @Binding var average: Double
    @State var rightText: String

    var body: some View {

        VStack {
            // title
            Text(title)
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            ZStack {

                // background
                Color(.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 4, x: 2, y: 2)

                VStack {

                    // chart
                    Chart(samples) { sample in

                        LineMark(
                            x: .value(sample.date.formatted(), sample.date, unit: .second),
                            y: .value(unit, sample.max)
                        )
                            .foregroundStyle(color.gradient)
                            .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value(sample.date.formatted(), sample.date, unit: .second),
                            y: .value(unit, sample.max)
                        )
                            .foregroundStyle(color.opacity(0.1).gradient)
                            .interpolationMethod(.catmullRom)
                    }

                        .padding()

                    // min max caption
                    HStack {
                        Text("MIN: \((samples.min(by: { $0.min < $1.min })?.min ?? 0).rounded().formatted()) \(unit)")
                        Text("MAX: \((samples.max(by: { $0.max < $1.max })?.max ?? 0).rounded().formatted()) \(unit)")
                        Spacer()
                        Text("\(rightText): \(average.formatted()) \(unit)")
                    }
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .foregroundStyle(color)
                        .bold()

                }
            }.padding(.horizontal)
        }
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

class ImageGenerator: ObservableObject {
    @Published var generatedImage: Image?

    func generateSharingImage(ride: Ride, displayScale: CGFloat) async {
        await MainActor.run {
            let view = RideShareView(ride: ride)
            let renderer = ImageRenderer(content: view)

            renderer.scale = displayScale

            // Give the view time to fully render
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let uiImage = renderer.uiImage {
                    self.generatedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

// MARK: - Previews
struct RideDetailView_Previews: PreviewProvider {

    static var previews: some View {

        RideDetailView(ride: PreviewRide)
//        RideDetailView(ride: PreviewRideNoRouteData).environmentObject(TrendManager())
//        ChartCardView(samples: PreviewRide.hrSamples, title: "Heart Rate", unit: "BPM", color: .red, average: 167, rightText: "AVG")
    }
}
