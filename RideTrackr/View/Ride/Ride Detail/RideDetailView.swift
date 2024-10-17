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
    @State var ride: Ride = Ride()
    @State private var isGeneratingImage = true
    @State private var selectedZone: HeartRateZone?
    @State private var selectedOverlay: MapOverlayType = .None
    @Namespace private var namespace
    @State var keyHigh: Double?
    @State var keyLow: Double?
    @State var colHigh: Color?
    @State var colLow: Color?

    

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
                            
                            RideMapView(
                                ride: ride,
                                selectedZone: $selectedZone,
                                selectedOverlay: $selectedOverlay,
                                keyHigh: $keyHigh,
                                keyLow: $keyLow,
                                colHigh: $colHigh,
                                colLow: $colLow
                            )
                                .toolbar(.hidden, for: .navigationBar)
                                .toolbar(.hidden, for: .tabBar)
                                .navigationTransition(.zoom(sourceID: "zoom", in: namespace))
                        } label: {
                            // map
                            LargeMapPreviewView(
                                routeData: ride.routeData,
                                temperatureString: ride.temperatureString,
                                effortScore: ride.effortScore,
                                selectedOverlay: $selectedOverlay,
                                ride: ride,
                                selectedZone: $selectedZone,
                                keyHigh: $keyHigh,
                                keyLow: $keyLow,
                                colHigh: $colHigh,
                                colLow: $colLow
                            )
                                .padding(.vertical, 20)
                                .padding()
                                .matchedTransitionSource(id: "zoom", in: namespace)

                        }.buttonStyle(.plain)

                        // ride preview
                        LargeRidePreview(ride: $ride, showDate: false, queryingHealthKit: .constant(false))
                            .padding()
                            .padding(.top, -30)
                        
                        CollapseView("Graphs", proxy: value) {
                                RideGraphsView(ride: $ride)
                                    .id("graphs")
                            }

                        if let _ = healthManager.restingHeartRate {

                            CollapseView("Heart Rate Zones", proxy: value) {

                                HeartRateZoneView(hrSamples: ride.hrSamples, rideDuration: ride.duration, selectedZone: $selectedZone)
                                    .padding(.top, -10)
                            }
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
                
                if ride.routeData.isEmpty {
                    self.ride = await DataManager.shared.updateRide(ride)
                }

                await imageGenerator.generateSharingImage(ride: ride, displayScale: displayScale)

                isGeneratingImage = false
                
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
