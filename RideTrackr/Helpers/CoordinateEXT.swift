//
//  CoordinateEXT.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//
import MapKit

extension MKCoordinateRegion {
    init?(from coordinates: [CLLocationCoordinate2D], buffer: Double) {
        guard coordinates.count > 1 else { return nil }
        
        let a = MKCoordinateRegion.region(coordinates, buffer: buffer, fix: { $0 }, fix2: { $0 })
        let b = MKCoordinateRegion.region(coordinates, buffer: buffer, fix: MKCoordinateRegion.fixMeridianNegativeLongitude, fix2: MKCoordinateRegion.fixMeridian180thLongitude)
        
        guard (a != nil || b != nil) else { return nil }
        guard (a != nil && b != nil) else {
            self = a ?? b!
            return
        }
        
        self = [a!, b!].min(by: { $0.span.longitudeDelta < $1.span.longitudeDelta }) ?? a!
    }
    
    var radius: CLLocationDistance {
        let furthest = CLLocation(latitude: self.center.latitude + (span.latitudeDelta / 2),
                                  longitude: center.longitude + (span.longitudeDelta / 2))
        return CLLocation(latitude: center.latitude, longitude: center.longitude).distance(from: furthest)
    }
    
    // MARK: - Private
    
    private static func region(_ coordinates: [CLLocationCoordinate2D], buffer: Double,
                               fix: (CLLocationCoordinate2D) -> CLLocationCoordinate2D,
                               fix2: (CLLocationCoordinate2D) -> CLLocationCoordinate2D) -> MKCoordinateRegion? {
        let t = coordinates.map(fix)
        let min = CLLocationCoordinate2D(latitude: t.min { $0.latitude < $1.latitude }!.latitude,
                                         longitude: t.min { $0.longitude < $1.longitude }!.longitude)
        let max = CLLocationCoordinate2D(latitude: t.max { $0.latitude < $1.latitude }!.latitude,
                                         longitude: t.max { $0.longitude < $1.longitude }!.longitude)
        
        // find span
        // multiply the deltas by 1.2 to create a buffer around the points
        let span = MKCoordinateSpan(latitudeDelta: (max.latitude - min.latitude) * buffer, longitudeDelta: (max.longitude - min.longitude) * buffer)
        
        // find center
        let center = CLLocationCoordinate2D(latitude: max.latitude - span.latitudeDelta / 2,
                                            longitude: max.longitude - span.longitudeDelta / 2)
        
        return MKCoordinateRegion(center: fix2(center), span: span)
    }
    
    private static func fixMeridianNegativeLongitude(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        guard (coordinate.longitude < 0) else { return coordinate }
        
        let fixedLng = 360 + coordinate.longitude
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: fixedLng)
    }
    
    private static func fixMeridian180thLongitude(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        guard (coordinate.longitude > 180) else { return coordinate }
        
        let fixedLng = -360 + coordinate.longitude
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: fixedLng)
    }
}
