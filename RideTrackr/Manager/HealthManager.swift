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


class HealthManager: ObservableObject {

    // MARK: - Properties

    private let healthStore = HKHealthStore()

    @Published var recentRide: Ride? = Ride()
    @Published var thisMonthRide: [Ride] = []
    @Published var thisWeekRides: [Ride] = []
    @Published var rides: [Ride] = []
    @Published var queryingHealthKit: Bool = true

    /// how often samples should be taken for things like heart rate and speed
    private let sampleInterval = DateComponents(second: 1)
    
    /// how many samples should be requested from healthkit for certain queries
    private let numberOfSamples = 2


    // MARK: - Init
    init() {
        
        queryingHealthKit = true
        
        // the type of data we are trying to access
        let workout = HKObjectType.workoutType()
        let heartRate = HKQuantityType(.heartRate)
        let workoutRoute = HKSeriesType.workoutRoute()

        let healhTypes: Set = [workout, heartRate, workoutRoute]

        // request authorisation from the user to access their health data
        Task {

            do {
                try await healthStore.requestAuthorization(toShare: [], read: healhTypes)
                
                syncWithHK()
                    
                
                
            } catch {
                print("Error authorising with health kit")
                
                queryingHealthKit = false
            }
        }
        
    }
    
    func syncWithHK() {
        
        Task {
            
            do {
                
                queryingHealthKit = true
                
                // query the workout data for this month's rides from healthkit
                let workouts = try await fetchCyclingWorkouts(startDate: .oneMonthAgo, endDate: Date())
                
                // iterare through the returned workouts
                for workout in workouts {
                    
                    // get the heart rate data for this workout
                    let hrSamples = try await fetchHeartRateSamples(for: workout, interval: sampleInterval)
                    
                    //
                    // get the average heart rate of this workout
                    let sumHRSamples = hrSamples.reduce(0.0) { $0 + (($1.min + $1.max) / 2) }
                    let averageHR = sumHRSamples / Double(hrSamples.count)
                    
                    //                    var workoutRoute: [CLLocation] = []
                    
                    
                    
                    getWorkoutRoute(workout: workout, numOfSamples: numberOfSamples) { (locations, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else if let locations = locations {
                            
                            var altitdueData: [StatSample] = []
                            var speedData: [StatSample] = []
                            
                            // get alituide data
                            for location in locations {
                                
                                let altitudeSample = StatSample(date: location.timestamp, min: location.altitude, max: location.altitude)
                                altitdueData.append(altitudeSample)
                            }
                            
                            // get speed data
                            for i in 0..<locations.count - 1 {
                                let startLocation = locations[i]
                                let endLocation = locations[i + 1]
                                
                                let distance = endLocation.distance(from: startLocation)
                                let timeInterval = endLocation.timestamp.timeIntervalSince(startLocation.timestamp)
                                
                                // claculate average speed
                                let averageSpeed = (distance / timeInterval) * 3.6
                                
                                let speedSample = StatSample(date: locations[i].timestamp, min: averageSpeed, max: averageSpeed)
                                speedData.append(speedSample)
                            }
                            
                            DispatchQueue.main.async {
                                self.rides.append(Ride(workout: workout,
                                                                averageHeartRate: averageHR,
                                                                hrSamples: hrSamples,
                                                                routeData: locations,
                                                                altitdueSamples: altitdueData,
                                                                speedSamples: speedData
                                                               ))
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    
                    let calendar = Calendar.current
                    let today = Date()
                    
                    self.recentRide = self.rides.first
                    
                    self.thisWeekRides = self.rides.filter { ride in
                        
                        
                        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                        let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
                        
                        
                        return ride.rideDate >= startOfWeek && ride.rideDate < endOfWeek
                    }
                    
                    self.thisMonthRide = self.rides.filter { ride in
                        
                        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!
                        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
                        
                        return ride.rideDate >= startOfMonth && ride.rideDate <= endOfMonth

                    }
                    
                    withAnimation {
                        self.queryingHealthKit = false
                    }
                    
                }
                
            } catch {
                print("error fetching health data")
                
                queryingHealthKit = false
            }
            
            
        }
        
    }
    
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
    
    func fetchAverageHeartRate(for workout: HKWorkout) async throws -> Double {
        
        // Define the heart rate type
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        // Create a predicate to only fetch heart rate samples associated with the workout
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        
        // Create a Task to handle the async query
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: workoutPredicate, options: .discreteAverage) { (query, statistics, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let quantity = statistics?.averageQuantity() {
                    let heartRateUnit = HKUnit(from: "count/min")
                    let averageHeartRate = quantity.doubleValue(for: heartRateUnit)
                    continuation.resume(returning: averageHeartRate)
                } else {
                    continuation.resume(throwing: NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch average heart rate"]))
                }
            }
            
            // Execute the query
            healthStore.execute(query)
        }
    }
    
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
    
    func getWorkoutRoute(workout: HKWorkout, numOfSamples: Int, completion: @escaping ([CLLocation]?, Error?) -> Void) {
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
                            
                            if locations.isEmpty || locationResult.timestamp.timeIntervalSince(locations.last!.timestamp) >= 5 {
                                locations.append(locationResult)
                            }
                        }
                        
//                        locations.append(contentsOf: locationResults)
//                        // Calculate the interval for even distribution
//                        let interval = max(locationResults.count / numOfSamples, 1)
//                        
//                        // Select samples at regular intervals
//                        for i in stride(from: 0, to: locationResults.count, by: interval) {
//                            locations.append(locationResults[i])
//                        }
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

// MARK: - HRSample

struct StatSample: Identifiable {
    let id = UUID()
    let date: Date
    let min: Double
    let max: Double
}

let previewStatSample = [

    StatSample(date: Date().addingTimeInterval(-172800), min: 72.0, max: 92.0),
    StatSample(date: Date().addingTimeInterval(-172740), min: 78.0, max: 98.0),
    StatSample(date: Date().addingTimeInterval(-172680), min: 83.0, max: 103.0),
    StatSample(date: Date().addingTimeInterval(-172620), min: 75.0, max: 95.0),
    StatSample(date: Date().addingTimeInterval(-172560), min: 80.0, max: 100.0),
    StatSample(date: Date().addingTimeInterval(-172500), min: 87.0, max: 106.0),
    StatSample(date: Date().addingTimeInterval(-172440), min: 90.0, max: 109.0),
    StatSample(date: Date().addingTimeInterval(-172380), min: 82.0, max: 102.0)
]

// MARK: - Extensions
extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var startOfWeekMonday: Date? {

        let calendar = Calendar.current
        let currentDate = Date()

        var startOfTheWeek: Date = Date()
        var interval: TimeInterval = 0

        let _ = calendar.dateInterval(of: .weekOfYear, start: &startOfTheWeek, interval: &interval, for: currentDate)

        return startOfTheWeek
    }

    static var oneMonthAgo: Date {
        let calendar = Calendar.current
        let oneMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        return calendar.startOfDay(for: oneMonth!)
    }
}
