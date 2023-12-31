//
//  RecentRidesCardList.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 1/11/2023.
//

import SwiftUI
import MapKit

struct RecentRidesCardList: View {

    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State var currentPage = 0

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

                }
                // MARK: - Tabview
                TabView(selection: $currentPage.animation()) {

                    ForEach(0..<healthManager.rides.prefix(5).dropFirst().count) { index in

                        NavigationLink(value: healthManager.rides[index]) {

                            RideCardPreview(ride: healthManager.rides[index]).padding(.horizontal).tag(index)
                                .foregroundStyle(Color.primary)
                                .containerRelativeFrame(.vertical)
                        }
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never))

                // MARK: - page indicator
                HStack(spacing: -5) {

                    ForEach(0..<healthManager.rides.prefix(5).dropFirst().count) { index in

                        Circle().foregroundStyle(index == currentPage ? Color.primary : Color.secondary)
                            .frame(height: index == currentPage ? 10 : 7)
                            .padding(7)
                            .onTapGesture {
                            withAnimation {
                                currentPage = index
                            }
                        }

                    }
                }.background {
                    Capsule()
                        .foregroundStyle(.ultraThinMaterial)

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

                MapSnapshotView(location: ride.routeData[0].coordinate, route: ride.routeData.map({ $0.coordinate }))
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
            
            // Set the stroke color and width for the route
            UIColor.accent.setStroke()
            
            // Create a path for the route
            let path = UIBezierPath()
            
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
