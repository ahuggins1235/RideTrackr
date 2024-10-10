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
    @Environment(\.displayScale) private var displayScale: CGFloat
    @ObservedObject var trendManager: TrendManager = .shared
    @ObservedObject var healthManager: HKManager = .shared
    @StateObject private var imageGenerator = ImageGenerator()
    @AppStorage("distanceUnit") private var distanceUnit: DistanceUnit = .Metric
    @State var ride: Ride = Ride()
    @State private var isGeneratingImage = true
    @State private var graphsExpanded = true
    @State private var heartRateExpanded = true
    @State private var selectedZone: HeartRateZone?
    @State private var selectedOverlay: MapOverlayType = .None
    @Namespace private var namespace

    private var heartRateZones: [HeartRateZone: TimeInterval] {
        return HeartRateZoneManager.shared.calculateZoneDurations(samples: ride.hrSamples)
    }

    // MARK: - Body
    var body: some View {

        ZStack {

            ScrollViewReader { value in
                ScrollView {

                    VStack(alignment: .leading) {


                        NavigationLink {
                            RideMapView(ride: ride, selectedZone: $selectedZone, selectedOverlay: $selectedOverlay)
                                .toolbar(.hidden, for: .navigationBar)
                                .toolbar(.hidden, for: .tabBar)
                                .navigationTransition(.zoom(sourceID: "zoom", in: namespace))
                        } label: {
                            // map
                            LargeMapPreviewView(routeData: ride.routeData, temperatureString: ride.temperatureString, effortScore: ride.effortScore, selectedOverlay: $selectedOverlay, ride: ride, selectedZone: $selectedZone)
                                .padding(.vertical, 20)
                                .padding()
                                .matchedTransitionSource(id: "zoom", in: namespace)

//                                    .frame(height: 500)

                        }.buttonStyle(.plain)

                        // ride preview
                        LargeRidePreview(ride: $ride, showDate: false, queryingHealthKit: .constant(false))
                            .padding()
                            .padding(.top, -30)

                        HStack {
                            Text("Graphs")
                                .font(.title3)
                            Spacer()
                            Label("Drop Down Arrow", systemImage: "chevron.right")
                                .rotationEffect(Angle(degrees: graphsExpanded ? 90 : 0))
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.secondary)
                        }
                            .id(0)
                            .padding()
                            .bold()
                            .contentShape(Rectangle())
                            .onTapGesture {
                            withAnimation {
                                graphsExpanded.toggle()
                                value.scrollTo(0, anchor: .top)
                            }
                        }

                        Divider()
                            .padding([.horizontal, .bottom])

                        if graphsExpanded {


                            VStack {

                                if ride.hrSamples.count != 0 {

                                    ChartCardView(
                                        title: "Heart Rate",
                                        rightText: "AVG",
                                        color: .heartRate,
                                        samples: $ride.hrSamples,
                                        unit: .constant("BPM"),
                                        average: .constant(ride.heartRate.rounded())
                                    ).padding(.bottom)

                                }

                                if ride.speedSamples.count != 0 {

                                    ChartCardView(
                                        title: "Speed",
                                        rightText: "AVG",
                                        color: .speed,
                                        samples: Binding(get: { ride.speedSamples.map({ stat in StatSample(date: stat.date, value: stat.value * distanceUnit.distanceConversion) }) }),
                                        unit: Binding(get: { "\(distanceUnit.speedAbr)" }),
                                        average: Binding(get: { (ride.speed * distanceUnit.distanceConversion).rounded() })
                                    ).padding(.bottom)

                                }

                                if ride.altitdueSamples.count != 0 {

                                    ChartCardView(
                                        title: "Altitude",
                                        rightText: "GAIN",
                                        color: .altitude,
                                        samples: Binding(get: { ride.altitdueSamples.map({ stat in StatSample(date: stat.date, value: stat.value * distanceUnit.smallDistanceConversion) }) }),
                                        unit: Binding(get: { "\(distanceUnit.smallDistanceAbr)" }),
                                        average: Binding(get: { (ride.altitudeGained * distanceUnit.smallDistanceConversion).rounded() })
                                    ).padding(.bottom)
                                }
                            }
                                .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity.combined(with: .move(edge: .bottom))
                                ))
                        }

                        if let _ = healthManager.restingHeartRate {

//                            HStack {
//                                Text("Heart Rate Zones")
//                                    .font(.title3)
//                                Spacer()
//                                Label("Drop Down Arrow", systemImage: "chevron.right")
//                                    .rotationEffect(Angle(degrees: heartRateExpanded ? 90 : 0))
//                                    .labelStyle(.iconOnly)
//                                    .foregroundStyle(.secondary)
//                            }
//                                .id(1)
//                                .padding()
//                                .bold()
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//
//                                withAnimation {
//                                    heartRateExpanded.toggle()
//                                    value.scrollTo(1, anchor: .top)
//                                }
//                            }
//
//                            Divider()
//                                .padding([.horizontal])
//
//                            if heartRateExpanded {
                            CollapseView("Heart Rate Zones") {
                                
                                
                                HeartRateZoneView(hrSamples: ride.hrSamples, rideDuration: ride.duration, selectedZone: $selectedZone)
                                    .padding(.top, -10)
                            }
//                            }
                        }
                    }
                    
                }
                    .background(Color(uiColor: .systemGroupedBackground))
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

    @State var title: String
    @State var rightText: String
    @State var color: Color
    @Binding var samples: [StatSample]
    @Binding var unit: String
    @Binding var average: Double

    var body: some View {

        VStack(alignment: .leading) {

            Text(title)
                .font(.headline)
                .bold()
                .padding(.leading)
                .padding(.top)
                .padding(.bottom, -15)


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
            .onAppear {
            HKManager.shared.restingHeartRate = 64
        }

//        RideDetailView(ride: PreviewRideNoRouteData).environmentObject(TrendManager())
//        ChartCardView(samples: PreviewRide.hrSamples, title: "Heart Rate", unit: "BPM", color: .red, average: 167, rightText: "AVG")
    }
}
