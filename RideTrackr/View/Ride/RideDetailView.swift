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
    @State var ride: Ride
    @Binding var show: Bool
    @State private var showingAlert = false
    @State var recentRide = false
    @Environment(\.displayScale) private var displayScale: CGFloat
    
    @MainActor
    private func generateSharingImage() -> Image {
        
        let renderer = ImageRenderer(content: RideShareView(ride: ride))
        
        renderer.scale = displayScale
        
        guard let image = renderer.uiImage else {
            showingAlert = true
            return Image(uiImage: UIImage())
        }
        
        return Image(uiImage: image)
    }
    
    var test: some View {
        
        VStack(alignment: .leading) {
            
            
            // map
            RideRouteMap(ride: $ride)
            
            // ride preview
            LargeRidePreview(ride: $ride, showDate: false, queryingHealthKit: .constant(false))
                .padding()
            
            ChartCardView(samples: ride.hrSamples,
                          title: "Heart Rate",
                          unit: "BPM",
                          color: .red,
                          average: ride.heartRate.rounded(),
                          rightText: "AVG"
            ).padding(.bottom)
            
            ChartCardView(samples: ride.speedSamples,
                          title: "Speed",
                          unit: "KM/H",
                          color: .blue,
                          average: ride.speed.rounded(),
                          rightText: "AVG"
            ).padding(.bottom)
            
            ChartCardView(samples: ride.altitdueSamples,
                          title: "Altitude",
                          unit: "m",
                          color: .mint,
                          average: ride.altitudeGained.rounded(),
                          rightText: "GAIN"
            ).padding(.bottom)
            
            
        }
        
    }
    
    // MARK: - Body
    var body: some View {

        ZStack {
            ScrollView {
                
                test

            }
            
        }
        .navigationTitle(ride.dateString)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                
                ShareLink(item: generateSharingImage(), preview: SharePreview("Ride Data", image: generateSharingImage()))
                
            }
        }
        .alert("Error sharing ride", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        
//            .overlay {
//
//            if recentRide {
//                VStack {
//                    HStack {
//
//                        Spacer()
//
//                        // ride date
//                        Text(ride.dateString)
//                            .font(.headline)
//                            .bold()
//                            .padding()
//
//                        Spacer()
//
//
//                    }
//                    // close button
//                    .overlay {
//                        HStack {
//                            Spacer()
//                            Button {
//                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                                    show.toggle()
//                                }
//
//                            } label: {
//                                Image(systemName: "xmark")
//                                    .bold()
//                                    .foregroundColor(.secondary)
//                                    .padding(7)
//                                    .background(.background, in: Circle())
//                            }
//                                .padding(.horizontal)
//                        }
//                    }
//                        .background(.ultraThinMaterial)
//                    Spacer()
//                }
//            }
//        }
            
    }
}

// MARK: - ChartCard
struct ChartCardView: View {

    @State var samples: [StatSample]
    @State var title: String
    @State var unit: String
    @State var color: Color
    @State var average: Double
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
                            y: .value(unit, (sample.max + sample.min) / 2)
                        )
                        .interpolationMethod(.catmullRom)
//                            .symbol() {
//                            Circle()
//                                .frame(width: 5)
//                        }
                    }
//                    .chartYScale(domain: 50...200)
                    .foregroundStyle(color)
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


    }
}

struct RideRouteMap: View {
    
    @Binding var ride: Ride
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(.secondary)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .blur(radius: 15)
                .padding()
            
            Map(interactionModes: MapInteractionModes.zoom) {
                
                MapPolyline(coordinates: ride.routeData.map { $0.coordinate }, contourStyle: .geodesic)
                    .stroke(.blue, lineWidth: 5)
                
                if let firstCoordindate = ride.routeData.first?.coordinate {
                    
                    Annotation("", coordinate: firstCoordindate) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 10)
                    }
                }
                
                if let lastCoordindate = ride.routeData.last?.coordinate {
                    
                    Annotation("", coordinate: lastCoordindate) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 10)
                    }
                }
                
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 300)
            .clipShape (
                RoundedRectangle(cornerRadius: 25)
        )
            .padding()
        }
        
    }
}

// MARK: - Previews
struct RideDetailView_Previews: PreviewProvider {

    @Namespace static var namespace

    static var previews: some View {

        RideDetailView(ride: PreviewRide, show: .constant(false), recentRide: false)
        RideDetailView(ride: PreviewRide, show: .constant(false), recentRide: true)
        ChartCardView(samples: PreviewRide.hrSamples, title: "Heart Rate", unit: "BPM", color: .red, average: 167, rightText: "AVG")
    }
}
