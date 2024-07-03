//
//  StatSample.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 21/6/2024.
//

import Foundation

/// represents a sample recorded during a workout
struct StatSample: Identifiable, Codable {
    let id: UUID
    
    /// when the sample was taken
    let date: Date
    
    /// the minimum value recorded during the sample
    let min: Double
    
    /// the maximuim value recored during the sample
    let max: Double
    
    init(id: UUID = UUID(), date: Date, min: Double, max: Double) {
        self.id = id
        self.date = date
        self.min = min
        self.max = max
    }
}
