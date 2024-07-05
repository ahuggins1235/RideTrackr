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
    var effortScore: Int?

    var body: some View {

        ZStack {

            Rectangle()
                .fill(.secondary)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .blur(radius: 15)
                .frame(height: 300)

            if let _ = routeData.first {

                Map(interactionModes: []) {
                    if let first = routeData.first {
                        Annotation("", coordinate: first.toCLLocationCoordinate2D()) {
                            Circle()
                                .fill(Color.accentColor)
                                .shadow(radius: 5)
                        }
                    }

                    MapPolyline(coordinates: routeData.map({ $0.toCLLocationCoordinate2D() }), contourStyle: .geodesic)
                        .stroke(Color.accentColor, lineWidth: 5)


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

                if let effortScore = effortScore {
                    VStack {
                        HStack {
                            Spacer()
                            EffortScoreView(score: effortScore)
                        }
                        Spacer()
                    }
                }

                if let temperature = temperatureString {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            TemperatureView(temperature: temperature)
                                .padding()
//                                .padding(5)
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
    }
}

#Preview {
    LargeMapPreviewView(routeData: PreviewRide.routeData, temperatureString: PreviewRide.temperatureString, effortScore: 5)
}
