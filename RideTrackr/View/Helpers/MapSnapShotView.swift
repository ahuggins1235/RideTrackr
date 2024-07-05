//
//  MapSnapShotView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 8/11/2023.
//

import SwiftUI
import MapKit

@MainActor
struct SmallMapPreviewView: View {
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

