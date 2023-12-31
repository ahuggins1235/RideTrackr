//
//  Ride.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import Foundation
import SwiftData
import HealthKit
import MapKit
import SwiftUI


class Ride: ObservableObject, Identifiable, Hashable {

    // MARK: - Base properties
    var id = UUID()

    /// the average heart rate recorded for this ride
    var heartRate: Double = 0
    /// the average speed recorded for this ride
    var speed: Double = 0
    /// the distance recorded for this ride
    var distance: Double = 0
    /// the active energy consumed during this ride
    var activeEnergy: Double = 0
    /// the amount of alitude gained during this ride
    var altitudeGained: Double = 0
    /// when this ride started
    var rideDate: Date = Date()
    /// the hkworkout this ride is based upon
    var hkWorkout: HKWorkout = HKWorkout.emptyWorkout
    /// the duration of this ride
    var duration: TimeInterval = 0
    /// the heart rate data recorded for this ride
    var hrSamples: [StatSample] = []
    /// the location data of the route of this ride
    var routeData: [CLLocation] = []
    /// the alititude data of this ride
    var altitdueSamples: [StatSample] = []
    /// the speed data of this ride
    var speedSamples: [StatSample] = []
    
    @AppStorage("distanceUnit") private var distanceUnit: DistanceUnit = .Kilometer
    @AppStorage("energyUnit") private var energyUnit: EnergyUnit = .Kilojule



    // MARK: - computed properties
    var heartRateString: String {
        return String(format: "%.0f", heartRate) + " BMP"
    }

    var speedString: String {
        return String(format: "%.1f", speed * distanceUnit.conversionValue) + " \(distanceUnit.abr)/H"
    }

    var distanceString: String {
        return String(format: "%.2f", distance * distanceUnit.conversionValue) + " \(distanceUnit.abr)"
    }

    var activeEnergyString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        return numberFormatter.string (from: NSNumber(value: activeEnergy * energyUnit.conversionValue))! + " \(energyUnit.abr)"
    }

    var durationString: String {

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]

        return formatter.string(from: duration)!
    }

    var alitudeString: String {
        return String(format: "%.1f", altitudeGained) + "m"
    }

    var dateString: String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "E, d'\(dateFormatter.ordinalSuffix(for: dateFormatter.calendar.component(.day, from: rideDate)))' MMM h:mma"
        return dateFormatter.string(from: rideDate)
    }

    var shortDateString: String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "E, d'\(dateFormatter.ordinalSuffix(for: dateFormatter.calendar.component(.day, from: rideDate)))' MMM"
        return dateFormatter.string(from: rideDate)
    }

    // MARK: - Inits

    /// default init
    init(id: UUID = UUID(),
        heartRate: Double = 0,
        speed: Double = 0,
        distance: Double = 0,
        activeEnergy: Double = 0,
        duration: TimeInterval = 0,
        altitudeGained: Double = 0,
        rideDate: Date = Date(),
        hrSamples: [StatSample] = [],
        routeData: [CLLocation] = [],
        altitdueSamples: [StatSample] = [],
         speedSamples: [StatSample] = []
    ) {
        self.id = id
        self.heartRate = heartRate
        self.speed = speed
        self.distance = distance
        self.activeEnergy = activeEnergy
        self.duration = duration
        self.altitudeGained = altitudeGained
        self.rideDate = rideDate
        self.hrSamples = hrSamples
        self.routeData = routeData
        self.altitdueSamples = altitdueSamples
        self.speedSamples = speedSamples
    }

    /// use this to create a new ride from an hkworkout
    init(workout: HKWorkout,
        averageHeartRate: Double,
        hrSamples: [StatSample] = [],
        routeData: [CLLocation] = [],
        altitdueSamples: [StatSample] = [],
        speedSamples: [StatSample] = []
    ) {

        // initalise required variables
        var (workoutActiveEnergy, workoutSpeed, workoutAlitudeGained, workoutDistance) = (0.0, 0.0, 0.0, 0.0)

        let activeEnergyStatistics = workout.allStatistics

        // iterate through all the statistics and assign the relevant ones to variables
        for (quantityType, statistic) in activeEnergyStatistics {

            switch quantityType {
                // print hello

                // active energy
            case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned):
                workoutActiveEnergy = (statistic.sumQuantity()?.doubleValue(for: HKUnit.joule()) ?? 0) / 1000

                // cycling distance
            case HKObjectType.quantityType(forIdentifier: .distanceCycling):
                workoutDistance = (statistic.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0) / 1000

            default:
                let _ = false
            }
        }

        // get the required data from the workout metedata
        if let workoutMetadata = workout.metadata {

            // workout elevation gained
            if let workoutElevation = workoutMetadata["HKElevationAscended"] as? HKQuantity {

                workoutAlitudeGained = workoutElevation.doubleValue(for: HKUnit.meter())
            }
        }

        // calculate averaege speed by dividing distance by time
        workoutSpeed = workoutDistance / (workout.duration / 3600)

        // set all properties
        self.heartRate = averageHeartRate
        self.speed = workoutSpeed
        self.distance = workoutDistance
        self.activeEnergy = workoutActiveEnergy
        self.duration = workout.duration
        self.altitudeGained = workoutAlitudeGained
        self.rideDate = workout.startDate
        self.hrSamples = hrSamples
        self.hkWorkout = workout
        self.routeData = routeData
        self.altitdueSamples = altitdueSamples
        self.speedSamples = speedSamples

    }

    // MARK: - Hashable Conformance

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.id == rhs.id
    }



}


// MARK: - Sample data
let PreviewRide = Ride(
    heartRate: 167.2,
    speed: 14.11111,
    distance: 7.9,
    activeEnergy: 1082,
    duration: 1000,
    altitudeGained: 13.7,
    rideDate: Date(),
    hrSamples: [
        StatSample(date: Date(), min: 70.0, max: 90.0),
        StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
        StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
        StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
        StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
        StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
        StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
        StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
    ],
    routeData: [
        CLLocation(latitude: 37.7749, longitude: -122.4194),
        CLLocation(latitude: 37.7739, longitude: -122.4222),
        CLLocation(latitude: 37.7729, longitude: -122.4250)
    ],
    altitdueSamples: [
        StatSample(date: Date(), min: 70.0, max: 90.0),
        StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
        StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
        StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
        StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
        StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
        StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
        StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
    ],
    speedSamples: [
        StatSample(date: Date(), min: 70.0, max: 90.0),
        StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
        StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
        StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
        StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
        StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
        StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
        StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
    ]
)


let previewRideArray: [Ride] = [
    Ride(
        heartRate: 167.2,
        speed: 14.11111,
        distance: 7.9,
        activeEnergy: 1082,
        duration: 1000,
        altitudeGained: 13.7,
        rideDate: Date(),
        hrSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ],
        routeData: [
            CLLocation(latitude: 37.7749, longitude: -122.4194),
            CLLocation(latitude: 37.7739, longitude: -122.4222),
            CLLocation(latitude: 37.7729, longitude: -122.4250)
        ],
        altitdueSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ],
        speedSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ]
    ),
    Ride(
        heartRate: 155.8,
        speed: 12.55,
        distance: 6.3,
        activeEnergy: 920,
        duration: 780,
        altitudeGained: 10.2,
        rideDate: Date().addingTimeInterval(-86400),
        hrSamples: [
            StatSample(date: Date().addingTimeInterval(-86400), min: 68.0, max: 88.0),
            StatSample(date: Date().addingTimeInterval(-86340), min: 73.0, max: 93.0),
            StatSample(date: Date().addingTimeInterval(-86280), min: 78.0, max: 98.0),
            StatSample(date: Date().addingTimeInterval(-86220), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(-86160), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(-86100), min: 82.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(-86040), min: 85.0, max: 103.0),
            StatSample(date: Date().addingTimeInterval(-85980), min: 77.0, max: 97.0)
        ],
        routeData: [
            CLLocation(latitude: 37.7749, longitude: -122.4194),
            CLLocation(latitude: 37.7739, longitude: -122.4222),
            CLLocation(latitude: 37.7729, longitude: -122.4250)
        ],
        altitdueSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ],
        speedSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ]
    ),
    Ride(
        heartRate: 177.5,
        speed: 16.82,
        distance: 9.4,
        activeEnergy: 1320,
        duration: 1250,
        altitudeGained: 15.3,
        rideDate: Date().addingTimeInterval(-172800),
        hrSamples: [
            StatSample(date: Date().addingTimeInterval(-172800), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(-172740), min: 78.0, max: 98.0),
            StatSample(date: Date().addingTimeInterval(-172680), min: 83.0, max: 103.0),
            StatSample(date: Date().addingTimeInterval(-172620), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(-172560), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(-172500), min: 87.0, max: 106.0),
            StatSample(date: Date().addingTimeInterval(-172440), min: 90.0, max: 109.0),
            StatSample(date: Date().addingTimeInterval(-172380), min: 82.0, max: 102.0)
        ],
        routeData: [
            CLLocation(latitude: 37.7749, longitude: -122.4194),
            CLLocation(latitude: 37.7739, longitude: -122.4222),
            CLLocation(latitude: 37.7729, longitude: -122.4250)
        ],
        altitdueSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ],
        speedSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ]
    ),
    Ride(
        heartRate: 142.6,
        speed: 10.25,
        distance: 5.7,
        activeEnergy: 780,
        duration: 620,
        altitudeGained: 8.1,
        rideDate: Date().addingTimeInterval(-2592000),
        hrSamples: [
            StatSample(date: Date().addingTimeInterval(-259200), min: 67.0, max: 87.0),
            StatSample(date: Date().addingTimeInterval(-259140), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(-259080), min: 77.0, max: 97.0),
            StatSample(date: Date().addingTimeInterval(-259020), min: 69.0, max: 89.0),
            StatSample(date: Date().addingTimeInterval(-258960), min: 74.0, max: 94.0),
            StatSample(date: Date().addingTimeInterval(-258900), min: 81.0, max: 101.0),
            StatSample(date: Date().addingTimeInterval(-258840), min: 84.0, max: 104.0),
            StatSample(date: Date().addingTimeInterval(-258780), min: 76.0, max: 96.0)
        ],
        routeData: [
            CLLocation(latitude: 37.7749, longitude: -122.4194),
            CLLocation(latitude: 37.7739, longitude: -122.4222),
            CLLocation(latitude: 37.7729, longitude: -122.4250)
        ],
        altitdueSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ],
        speedSamples: [
            StatSample(date: Date(), min: 70.0, max: 90.0),
            StatSample(date: Date().addingTimeInterval(60), min: 75.0, max: 95.0),
            StatSample(date: Date().addingTimeInterval(120), min: 80.0, max: 100.0),
            StatSample(date: Date().addingTimeInterval(180), min: 72.0, max: 92.0),
            StatSample(date: Date().addingTimeInterval(240), min: 78.0, max: 96.0),
            StatSample(date: Date().addingTimeInterval(300), min: 85.0, max: 102.0),
            StatSample(date: Date().addingTimeInterval(360), min: 88.0, max: 105.0),
            StatSample(date: Date().addingTimeInterval(420), min: 76.0, max: 94.0)
        ]
    )
]


// MARK: - Helpers
extension DateFormatter {

    /// Returns an ordinal suffix to depending on what day of the month is passed in
    func ordinalSuffix(for day: Int) -> String {

        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

extension HKWorkout {

    static let emptyWorkout = HKWorkout(activityType: .cycling, start: Date(), end: Date())

}
