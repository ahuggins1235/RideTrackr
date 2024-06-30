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
    @State var ride: Ride = Ride()
    @Environment(\.displayScale) private var displayScale: CGFloat
    @EnvironmentObject var trendManager: TrendManager
    @AppStorage("distanceUnit") private var distanceUnit: DistanceUnit = .Metric

    @MainActor
    private func generateSharingImage() -> Image {

        let renderer = ImageRenderer(content: RideShareView(ride: ride).environmentObject(trendManager))

        renderer.scale = displayScale

        guard let image = renderer.uiImage else {
            return Image(uiImage: UIImage())
        }

        return Image(uiImage: image)
    }

    // MARK: - Body
    var body: some View {

        ZStack {
            ScrollView {

                VStack(alignment: .leading) {

                    // map
                    ZStack {
                        
                         if let location = ride.routeData.first {
                        
                        Rectangle()
                            .fill(.secondary)
                            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .blur(radius: 15)
                            .padding()

                            MapSnapshotView(location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), route: ride.routeData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }) )
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                .padding()
                                .frame(height: 300)
                            
                            if let _ = ride.temperature {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        TemperatureView(temperature: ride.temperatureString).padding().padding(.top)
                                    }
                                }
                            }
                            
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

                    // ride preview
                    LargeRidePreview(ride: $ride, showDate: false, queryingHealthKit: .constant(false))
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
                        
                        ChartCardView(samples: Binding(get: { ride.speedSamples.map({ stat in StatSample(date: stat.date, min: stat.min * distanceUnit.distanceConversion , max: stat.max * distanceUnit.distanceConversion  ) } ) } ),
                                      title: "Speed",
                                      unit: Binding(get: { "\(distanceUnit.speedAbr)" }),
                                      color: .speed,
                                      average: Binding(get: { (ride.speed * distanceUnit.distanceConversion).rounded() } ),
                                      rightText: "AVG"
                        ).padding(.bottom)
                        
                    }

                    if ride.altitdueSamples.count != 0 {
                        
                        ChartCardView(samples: Binding(get: { ride.altitdueSamples.map({ stat in StatSample(date: stat.date, min: stat.min * distanceUnit.smallDistanceConversion , max: stat.max * distanceUnit.smallDistanceConversion  ) } ) } ) ,
                                      title: "Altitude",
                                      unit: Binding(get: { "\(distanceUnit.smallDistanceAbr)" }),
                                      color: .altitude,
                                      average: Binding(get: { (ride.altitudeGained * distanceUnit.smallDistanceConversion).rounded() } ),
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

                ShareLink(item: generateSharingImage(), preview: SharePreview("Ride Data", image: generateSharingImage()))

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
//                    let max = samples.max { sample1, sample2 in
//                        sample1.max > sample2.max
//                    }?.max ?? 0
//                    
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
//                    .chartYScale (domain: 0...(max + 100))

                        .padding()
                        

//                        .onAppear {
//                            for (index,_) in samples.enumerated() {
////                                withAnimation(.interactiveSpring(response: 0.8,
////                                                                 dampingFraction: 0.8,
////                                                                 blendDuration: 0.8).delay(Double(index) * 0.05)) {
////                                    samples[index].animate = true
////                                }
//                                withAnimation(.easeInOut(duration:1)) {
//                                    samples[index].animate = true
//                                }
//                            }
//                        }

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

struct AnimationModifier : ViewModifier{
    let positionOffset : Double
    let height = UIScreen.main.bounds.height
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let position = geometry.frame(in: CoordinateSpace.global).midY
            ZStack {
                Color.clear
                if height >= (position + positionOffset)  {
                    content
                }
            }
        }
    }
}


// MARK: - Previews
struct RideDetailView_Previews: PreviewProvider {

    @Namespace static var namespace

    static var previews: some View {
        
        RideDetailView(ride: PreviewRide).environmentObject(TrendManager())
//        RideDetailView(ride: PreviewRideNoRouteData).environmentObject(TrendManager())
//        ChartCardView(samples: PreviewRide.hrSamples, title: "Heart Rate", unit: "BPM", color: .red, average: 167, rightText: "AVG")
    }
}
