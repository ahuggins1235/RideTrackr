//
//  HealthManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import Foundation
import HealthKit
import MapKit
import Combine
import SwiftUI
import SwiftData

/// responsible for managing all healthkit related activites in the app
class HealthManager: ObservableObject {

    // MARK: - Properties

//    @Environment(\.modelContext) private var context
    private let healthStore = HKHealthStore()

    /// the users most recent ride
    @Published var recentRide: Ride? = Ride()
    /// all of the ride the user has been on this month
    @Published var thisMonthRide: [Ride] = []
    /// all of the rides the user has been on this week
    @Published var thisWeekRides: [Ride] = []
    /// all of the rides the user has been on
    @Published var rides: [Ride] = []
    /// true if an active query to health kit is being performed false if not
    @Published var queryingHealthKit: Bool = true

    /// how often samples should be taken for things like heart rate and route data
    private let sampleInterval = DateComponents(second: 1)


    // MARK: - Init

    /// initialises the health manager
    init() {

        queryingHealthKit = true

        Task {

//            while true {

            let healthKitAuthorised = await authoriseHealthKit()

            if !healthKitAuthorised {

                print("An error occured when authorising with HealthKit")

//            }

        }

        queryingHealthKit = false

//            let sucessfullSync = await syncWithHK()

//            if !sucessfullSync {
//                print("error fetching health data")
//                return
//            }
    }
}

// MARK: - Setup functions


/// attempts to attain authorisation from the user to access their healthkit data
/// - Returns: true if the request to authorise with health kit was successfull, false if there was an error
func authoriseHealthKit() async -> Bool {

    // the type of data we are trying to access
    let workout = HKObjectType.workoutType()
    let heartRate = HKQuantityType(.heartRate)
    let workoutRoute = HKSeriesType.workoutRoute()

    let healhTypes: Set = [workout, heartRate, workoutRoute]

    Task {
        do {
            try await healthStore.requestAuthorization(toShare: [], read: healhTypes)

        } catch {
            return false
        }
        return true
    }
    return true
}


/// attempts to query the user's healthstore to get all of their rides within the given timeframe and assemble them into ride objects for the appropriate properties
/// - Parameter queryDate: the start of the date range for the healthkit query
/// - Returns: true if the sync was successfull, false if there was an error
func syncRides(queryDate: Date) async -> [Ride] {

    DispatchQueue.main.async {

        self.queryingHealthKit = true
    }

    var rides: [Ride] = []

    // conduct healthkit queries
    do {


        // query the workout data for this month's rides from healthkit
        let workouts = try await fetchCyclingWorkouts(startDate: queryDate, endDate: Date())

        // iterare through the returned workouts
        for workout in workouts {

            // get the heart rate data for this workout
            let hrSamples = try await fetchHeartRateSamples(for: workout, interval: sampleInterval)

            // calculate the average heart rate of this workout
            let sumHRSamples = hrSamples.reduce(0.0) { $0 + (($1.min + $1.max) / 2) }
            let averageHR = sumHRSamples / Double(hrSamples.count)


            // get workoutroute
            if let locations = try await fetchWorkoutRoute(workout: workout) {

                var altitdueData: [StatSample] = []
                var speedData: [StatSample] = []

                // get alituide data
                for location in locations {

                    let altitudeSample = StatSample(date: location.timestamp, min: location.altitude, max: location.altitude)
                    altitdueData.append(altitudeSample)
                }

                if locations.count != 0 {

                    // get speed data
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

                let ride = Ride(workout: workout,
                    averageHeartRate: averageHR,
                    hrSamples: hrSamples,
                    routeData: locations.map({ PersistentLocation(location: $0) }),
                    altitdueSamples: altitdueData.sorted(by: { $0.date < $1.date }),
                    speedSamples: speedData.sorted(by: { $0.date < $1.date })
                )

                rides.append(ride)
            }
        }

        DispatchQueue.main.async {
            withAnimation {
                self.queryingHealthKit = false
            }
        }



        return rides

    } catch {

        queryingHealthKit = false

        return rides
    }
}


/// filters the rides list by week and by month and assigns those values to the appropriate properties
private func dateFilterRideLists() {
    DispatchQueue.main.async {

        let calendar = Calendar.current
        let today = Date()

        // get the most recent ride
        self.recentRide = self.rides.first

        // filter the rides to only contain rides this week
        self.thisWeekRides = self.rides.filter { ride in

            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!


            return ride.rideDate >= startOfWeek && ride.rideDate < endOfWeek
        }

        // filter the rides to only contain rides this month
        self.thisMonthRide = self.rides.filter { ride in

            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

            return ride.rideDate >= startOfMonth && ride.rideDate <= endOfMonth

        }
    }
}

// MARK: - HealthKit Query functions


/// fetch cycling workouts that were completed within the given date range
/// - Parameters:
///   - startDate: The start of the date range
///   - endDate: the end of the date range
/// - Returns: all of the `HKWorkout` objects that are within the specified date range
func fetchCyclingWorkouts(startDate: Date, endDate: Date) async throws -> [HKWorkout] {

    // Define the workout type
    let workoutType = HKObjectType.workoutType()

    // Create a predicate to only fetch workouts within the specified date range
    let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

    // Create a predicate to only fetch cycling workouts
    let cyclingPredicate = HKQuery.predicateForWorkouts(with: .cycling)

    // Combine the predicates
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, cyclingPredicate])

    // Define the sort descriptor to sort workouts by end date
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

    // Create a Task to handle the async query
    return try await withCheckedThrowingContinuation { continuation in
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
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

}

// MARK: - StatSample


/// represents a sample recorded during a workout
@Model
class StatSample: Identifiable {
    let id = UUID()

    /// when the sample was taken
    let date: Date

    /// the minimum value recorded during the sample
    let min: Double

    /// the maximuim value recored during the sample
    let max: Double

    /// used to animated this sample
    var animate: Bool = false

    init(date: Date, min: Double, max: Double) {
        self.date = date
        self.min = min
        self.max = max
        self.animate = animate
    }
}
