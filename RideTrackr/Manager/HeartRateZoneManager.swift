//
//  HeartRateZoneManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 7/10/2024.
//

import Foundation
import SwiftUI

class HeartRateZoneManager: ObservableObject {

    public static let shared = HeartRateZoneManager()

    private let maxHeartRate: Double

    private var HRR: Double {
        return self.maxHeartRate - (HKManager.shared.restingHeartRate ?? 60)
    }

    init() {
        self.maxHeartRate = 220.0 - Double(HKManager.shared.userAge ?? 20)
//        self.maxHeartRate =  207 - (0.7 * Double(HKManager.shared.userAge ?? 20))
        print(self.maxHeartRate)
        print(HKManager.shared.restingHeartRate)

    }

    // Get zone for a specific heart rate
    func getZone(heartRate: Double, restingHR: Double? = nil) -> HeartRateZone {
        let percentage: Double
        
        if let restingHR = restingHR {
            // Use heart rate reserve (Karvonen) method
            let hrr = maxHeartRate - restingHR
            percentage = (heartRate - restingHR) / hrr
        } else {
            // Use simple percentage of max HR method
            percentage = heartRate / maxHeartRate
        }
        
        switch percentage {
            case ..<0.6:
                return .veryLight
            case 0.6..<0.7:
                return .light
            case 0.7..<0.8:
                return .moderate
            case 0.8..<0.9:
                return .hard
            case 0.9...:
                return . veryHard
            default:
                return .veryLight
        }
    }
    
    // Calculate time spent in each zone
    func calculateZoneDurations(samples: [StatSample], restingHR: Double? = nil) -> [HeartRateZone: TimeInterval] {
        var zoneDurations: [HeartRateZone: TimeInterval] = [:]
        
        // Initialize all zones to 0 duration
        HeartRateZone.allCases.forEach { zoneDurations[$0] = 0 }
        
        // Process each sample
        for i in 0..<samples.count {
            let sample = samples[i]
            var duration: TimeInterval
            
            // Calculate duration between samples
            if i < samples.count - 1 {
                duration = samples[i + 1].date.timeIntervalSince(sample.date)
            } else {
                // For the last sample, use the same duration as the previous interval
                // or a default duration if it's the only sample
                duration = i > 0 ?
                sample.date.timeIntervalSince(samples[i - 1].date) :
                TimeInterval(60) // 1 minute default for single sample
            }
            
            // Determine zone based on max heart rate and add duration
            let zone = getZone(heartRate: sample.max, restingHR: restingHR)
            zoneDurations[zone] = (zoneDurations[zone] ?? 0) + duration
        }
        
        return zoneDurations
    }
    
    // Format duration for display
    static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }


}

enum HeartRateZone: Int, CaseIterable, Identifiable {
    case veryLight = 1
    case light
    case moderate
    case hard
    case veryHard
    
    var id: Int { self.rawValue }
    
    var description: String {
        switch self {
            case .veryLight: return "Very Light"
            case .light: return "Light"
            case .moderate: return "Moderate"
            case .hard: return "Hard"
            case .veryHard: return "Very Hard"
        }
    }
    var colour: Color {
        switch self {
            case .veryLight:
                return .blue
            case .light:
                return .cyan
            case .moderate:
                return .green
            case .hard:
                return .orange
            case .veryHard:
                return .red
        }
    }
}
