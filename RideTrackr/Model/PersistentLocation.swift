//
//  PersistentLocation.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 30/6/2024.
//

import Foundation
import CoreLocation

struct PersistentLocation: Identifiable, Hashable, Codable {
    
    var id = UUID()
    var latitude: Double
    var longitude: Double
    var timeStamp: Date
    
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timeStamp = location.timestamp
    }
    
    init(id: UUID = UUID(), latitude: Double, longitude: Double, timeStamp: Date) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timeStamp = timeStamp
    }
    
    func toCLLocation() -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: self.timeStamp)
    }
}
