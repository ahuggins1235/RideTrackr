//
//  HKManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 13/6/2024.
//

import Foundation
import HealthKit
import MapKit
import Combine
import SwiftUI


final class HKManager: ObservableObject {

    // MARK: - public properties
    public static let shared = HKManager()
    /// Whether or not to display an alert to the user
    @Published var showAlert = false
    @Published var alertMessage = ""
    /// Whether or not a healthkit query is running
    @Published var queryingHealthKit = false

    // MARK: - private properties
    private let healthStore = HKHealthStore()
    private let sampleInterval = DateComponents(second: 15)
    private let recentRidesSynced = 5

    // MARK: - Init
    init() {
        requestAuthorization()

    }

    // MARK: - HK Queries


    /// Gets a list of rides the user has recorded
    /// - Parameter numRides: How many rides to get
    /// - Returns: An array of ``Ride`` objects that represent some of the rides the user has been on
    func getRides(numRides: Int = 1, getAllRides: Bool = false) async -> [Ride] {

        var rides: [Ride] = []

        do {

            let workouts = try await fetchCyclingWorkouts(numRides: numRides, getAllRides: getAllRides)

//            try await fetchEffortScore(for: workouts.first!)

            // iterare through the returned workouts
            for workout in workouts {

                // get the heart rate data for this workout
                let hrSamples = try await fetchHeartRateSamples(for: workout, interval: sampleInterval)

                // calculate the average heart rate of this workout
                let sumHRSamples = hrSamples.reduce(0.0) { $0 + (($1.min + $1.max) / 2) }
                let averageHR = sumHRSamples / Double(hrSamples.count)


                // get workoutroute
                if let locations = try await fetchWorkoutRoute(workout: workout) {
                    
                    // get effort score
                    let effortScore = try await fetchWorkoutEffortSamples(for: workout)


                    let (speedData, altitdueData) = calculateSpeedAndAltitude(locations: locations)
                    
                    let ride = Ride(workout: workout,
                        averageHeartRate: averageHR,
                        effortScore: effortScore,
                        hrSamples: hrSamples,
                        routeData: locations.map({ PersistentLocation(location: $0) }),
                        altitdueSamples: altitdueData.sorted(by: { $0.date < $1.date }),
                        speedSamples: speedData.sorted(by: { $0.date < $1.date })
                    )

                    rides.append(ride)
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error while getting rides: \(error.localizedDescription)")
                self.alertMessage = "Error while getting rides."
                self.showAlert = true
            }
        }
        return rides
    }


    /// Queries health kit for an array of cycling workouts
    /// - Parameter numRides: how many workouts to collect
    /// - Returns: an array of ``HKWorkout``
    func fetchCyclingWorkouts(numRides: Int = 1, getAllRides: Bool = false) async throws -> [HKWorkout] {
        
        
        
        // Define the workout type
        let workoutType = HKObjectType.workoutType()

        // Create a predicate to only fetch cycling workouts
        let predicate = HKQuery.predicateForWorkouts(with: .cycling)

        // Define the sort descriptor to sort workouts by end date
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        // Create a Task to handle the async query
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: getAllRides ? HKObjectQueryNoLimit : numRides, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let samples = samples as? [HKWorkout] {
                    continuation.resume(returning: samples)
                } else {
                    continuation.resume(throwing: NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch workouts"]))
                }
            }

            // Execute the query
            healthStore.execute(query)
        }
    }

    /// Fetch all of the heart rate samples that were recorded during the user's workout
    /// - Parameters:
    ///   - workout: The workout that is being queried
    ///   - interval: how often we should collect samples
    /// - Returns: an array of ``StatSample`` that represents all of the heart rate samples recorded during the workout
    func fetchHeartRateSamples(for workout: HKWorkout, interval: DateComponents) async throws -> [StatSample] {

        // Define the heart rate type
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        // Create a predicate to only fetch heart rate samples associated with the workout
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)

        // Create a statistics collection query with the specified interval
        let query = HKStatisticsCollectionQuery(quantityType: heartRateType, quantitySamplePredicate: workoutPredicate, options: [.discreteAverage, .separateBySource], anchorDate: workout.startDate, intervalComponents: interval)

        // Create a Task to handle the async query
        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { query, statisticsCollection, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let statisticsCollection = statisticsCollection {
                    var samples = [StatSample]()
                    statisticsCollection.enumerateStatistics(from: workout.startDate, to: workout.endDate) { statistics, _ in
                        if let quantity = statistics.averageQuantity() {
                            let heartRateUnit = HKUnit(from: "count/min")
                            let averageHeartRate = quantity.doubleValue(for: heartRateUnit)
                            let sample = StatSample(date: statistics.startDate, min: averageHeartRate, max: averageHeartRate)
                            samples.append(sample)
                        }
                    }
                    continuation.resume(returning: samples)
                } else {
                    continuation.resume(throwing: NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch heart rate samples"]))
                }
            }

            // Execute the query
            healthStore.execute(query)
        }
    }

    func fetchWorkoutEffortSamples(for workout: HKWorkout) async throws -> Double? {
        let workoutEffortScoreType = HKObjectType.quantityType(forIdentifier: .estimatedWorkoutEffortScore)!

        // Create the predicate for effort samples related to the workout
        let effortPredicate = HKQuery.predicateForWorkoutEffortSamplesRelated(workout: workout, activity: nil)

        // Perform the query asynchronously using withCheckedThrowingContinuation
        return try await withCheckedThrowingContinuation { continuation in
            let effortQuery = HKSampleQuery(sampleType: workoutEffortScoreType, predicate: effortPredicate, limit: 0, sortDescriptors: nil) { (query, results, error) in

                if let error = error {
                    // Pass the error to the continuation
                    continuation.resume(throwing: error)
                    return
                }

                guard let effortSamples = results as? [HKQuantitySample], !effortSamples.isEmpty else {
                    // If no samples, return 0
                    continuation.resume(returning: 0)
                    return
                }

                let effortScore = effortSamples.first?.quantity.doubleValue(for: HKUnit.appleEffortScore())

                // Resume with the total score
                continuation.resume(returning: effortScore)

            }

            // Execute the query
            healthStore.execute(effortQuery)
        }
    }
//    func fetchWorkoutEffortSamples(for workout: HKWorkout) -> Int? {
//        let workoutEffortScoreType = HKObjectType.quantityType(forIdentifier: .estimatedWorkoutEffortScore)
//
//        // Create the predicate for effort samples related to the workout
//        let effortPredicate = HKQuery.predicateForWorkoutEffortSamplesRelated(workout: workout, activity: nil)
//
//        // Create the query
//        let effortQuery = HKSampleQuery(sampleType: workoutEffortScoreType!, predicate: effortPredicate, limit: 0, sortDescriptors: nil) { (query, results, error) in
//
//            guard let effortSamples = results as? [HKQuantitySample] else {
//                print("No effort samples found or error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            // Process the effort samples
//            for sample in effortSamples {
//                print("Effort Score: \(sample.quantity.doubleValue(for: HKUnit.appleEffortScore()))")
//
//            }
//        }
//
//        // Execute the query
//        healthStore.execute(effortQuery)
//    }

    /// Fetches the route the user took on the given workout
    /// - Parameters:
    ///   - workout: the wokrout that is being queried
    func fetchWorkoutRoute(workout: HKWorkout) async throws -> [CLLocation]? {
        try await withCheckedThrowingContinuation { continuation in
            fetchWorkouRoute(workout: workout) { (result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    /// Fetches the route the user took on the given workout
    /// - Parameters:
    ///   - workout: the wokrout that is being queried
    ///   - completion: _
    private func fetchWorkouRoute(workout: HKWorkout, completion: @escaping ([CLLocation]?, Error?) -> Void) {

        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: workoutPredicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let routes = samples as? [HKWorkoutRoute] else {
                completion(nil, nil)
                return
            }

            var locations: [CLLocation] = []
            let dispatchGroup = DispatchGroup()

            for route in routes {
                dispatchGroup.enter()
                let locationQuery = HKWorkoutRouteQuery(route: route) { (query, locationResults, done, error) in
                    guard error == nil else {
                        dispatchGroup.leave()
                        return
                    }

                    if let locationResults = locationResults {

                        for locationResult in locationResults {

                            if locations.isEmpty || locationResult.timestamp.timeIntervalSince(locations.last!.timestamp) > Double(self.sampleInterval.value(for: .second)!) {

                                locations.append(locationResult)

                            }
                        }
                    }

                    if done {
                        dispatchGroup.leave()
                    }
                }

                self.healthStore.execute(locationQuery)
            }

            dispatchGroup.notify(queue: .main) {
                completion(locations, nil)
            }
        }

        healthStore.execute(routeQuery)
    }

    // MARK: - Helpers

    /// attemps to attain authorisation from the user to access their health data
    private func requestAuthorization() {
        // Ensure HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let workoutType = HKObjectType.workoutType()
        let workoutRouteType = HKSeriesType.workoutRoute()
        let effortType = HKObjectType.quantityType(forIdentifier: .estimatedWorkoutEffortScore)!

        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType, workoutType, workoutRouteType, effortType]) { (success, error) in

            DispatchQueue.main.async {
                if success {
                    print("HealthKit authorization request was successful.")
                } else {
                    if let error = error {
                        print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                        self.alertMessage = "Error requesting HealthKit authorization: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        print("HealthKit authorization was not granted.")
                        self.alertMessage = "HealthKit authorization was not granted."
                        self.showAlert = true
                    }
                }
            }
        }
    }

    /// caluclates the speed and altitude samples of a ride using the location data
    /// - Parameter locations: the route data of a ride
    /// - Returns: a tuple containing and array of speed samples and altituide samples
    func calculateSpeedAndAltitude(locations: [CLLocation]) -> (speedSamples: [StatSample], altitudeSamples: [StatSample]) {

        var altitdueData: [StatSample] = []
        var speedData: [StatSample] = []

        // get alituide data
        for location in locations {

            let altitudeSample = StatSample(date: location.timestamp, min: location.altitude, max: location.altitude)
            altitdueData.append(altitudeSample)
        }

        // get speed data
        if locations.count != 0 {

            for i in 0..<locations.count - 1 {

                let startLocation = locations[i]
                let endLocation = locations[i + 1]

                let distance = endLocation.distance(from: startLocation)
                let timeInterval = endLocation.timestamp.timeIntervalSince(startLocation.timestamp)

                // calculate average speed
                let averageSpeed = (distance / timeInterval) * 3.6

                let speedSample = StatSample(date: locations[i].timestamp, min: averageSpeed, max: averageSpeed)
                speedData.append(speedSample)
            }
        }
        return (speedData, altitdueData)
    }
}
