//
//  RecentRidesCardList.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 1/11/2023.
//

import SwiftUI
import MapKit
import SwiftData

struct RecentRidesCardList: View {

    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State var currentRide = UUID()
    @Environment(\.modelContext) var context
    @Query(sort: \Ride.rideDate, order: .reverse) var rides: [Ride]

    var body: some View {

        NavigationStack {

            VStack {

                // MARK: - Header
                HStack {
                    Text("Recent Rides")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.accent)

                    Spacer()

                    Text("Show more...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.accent)
                        .onTapGesture {
                        navigationManager.selectedTab = .RideList
                    }

                }.offset(y: 15)
                // MARK: - Tabview
                
                if rides.count >= 2 {
                    
                    TabView(selection: $currentRide.animation()) {
                        
                        ForEach(rides.prefix(5).dropFirst()) { ride in
                            
                            NavigationLink(value: ride) {
                                
                                RideCardPreview(ride: ride).padding(.horizontal).tag(ride.id)
                                    .foregroundStyle(Color.primary)
                                    .containerRelativeFrame(.vertical)
                            }
                        }
                    }.tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // MARK: - page indicator
                    HStack(spacing: -5) {
                        
                        ForEach(rides.prefix(5).dropFirst()) { ride in
                            
                            Circle().foregroundStyle(ride.id == currentRide ? Color.primary : Color.secondary)
                                .frame(height: ride.id == currentRide ? 10 : 7)
                                .padding(7)
                                .onTapGesture {
                                    withAnimation {
                                        currentRide = ride.id
                                    }
                                }
                            
                        }
                    }.background {
                        Capsule()
                            .foregroundStyle(.ultraThinMaterial)
                        
                    }
                    // set the idicator to the second ride
                    .onAppear {
                        
                        currentRide = rides[1].id
                        
                    }
                } else {
                    Text("No recent rides found")
                        .padding()
                }

            }.padding(.vertical)
                .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }
        }
    }

}


#Preview {
    RecentRidesCardList().environmentObject(HealthManager()).environmentObject(NavigationManager()).padding()
}

struct RideCardPreview: View {

    @State var ride: Ride

    var body: some View {

        ZStack {

            Color.cardBackground
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(radius: 4, x: 2, y: 2)

            HStack {
                VStack(alignment: .center, spacing: 10) {

                    Text(ride.dateString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 5) {
                        Text(ride.distanceString)
                            .foregroundStyle(.distance)

                        Text(ride.activeEnergyString)
                            .foregroundStyle(.energy)

                    }.bold()
                        .font(.headline)
                        .padding(.vertical)

                    Text(ride.durationString)
                        .fontWeight(.semibold)

                }
                    .padding(.leading)

                MapSnapshotView(location: CLLocationCoordinate2D(latitude: ride.routeData.first!.latitude, longitude: ride.routeData.first!.longitude), route: ride.routeData.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .padding()

//                RideRouteMap(ride: $ride)
//                    .frame(width: 200, height: 150)
//                    .padding(.leading)
//                    .padding(.trailing, 12)

            }
        }
            .frame(height: 175)

    }
}

struct MapSnapshotView: View {
    let location: CLLocationCoordinate2D
    var span: CLLocationDegrees = 0.01
    let route: [CLLocationCoordinate2D]
    @State var routeWidth: Double = 4.0

    @State private var snapshotImage: UIImage? = nil

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = snapshotImage {
                    Image(uiImage: image)
                } else {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
                .onAppear {
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    func generateSnapshot(width: CGFloat, height: CGFloat) {

        // The region the map should display.
//        let region = MKCoordinateRegion(
//            center: self.location,
//            span: MKCoordinateSpan(
//                latitudeDelta: self.span,
//                longitudeDelta: self.span
//            )
//        )

        let region = MKCoordinateRegion(from: route, buffer: 1.1)!

        // Map options.
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true

        // Create the snapshotter and run it.
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                self.snapshotImage = drawRoute(on: snapshot.image, with: snapshot)
            }
        }
    }

    // Draw the route on the snapshot image
    func drawRoute(on image: UIImage, with snapshot: MKMapSnapshotter.Snapshot) -> UIImage {
        // Create a renderer to draw on the image
        let renderer = UIGraphicsImageRenderer(size: image.size)

        // Render the image with the route overlay
        return renderer.image { context in
            // Draw the original image
            image.draw(at: .zero)

            // Create a path for the route
            let path = UIBezierPath()
            
            // Set the stroke color and width for the route
            UIColor.accent.setStroke()
            path.lineWidth = routeWidth

            // Move to the first point in the route
            let firstPoint = snapshot.point(for: route[0])
            path.move(to: firstPoint)

            // Add lines to the rest of the points in the route
            for coordinate in route.dropFirst() {
                let point = snapshot.point(for: coordinate)
                path.addLine(to: point)
            }

            // Stroke the path
            path.stroke()
        }
    }
}

#Preview {
    RideCardPreview(ride: PreviewRide)
}
