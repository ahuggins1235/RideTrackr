//
//  DataManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 16/11/2023.
//

import Foundation
import FMDB
import WidgetKit

class DataManager: ObservableObject {

    private let db: FMDatabase
    public static let shared = DataManager()
    @Published var rides = [Ride]()

    init(fileName: String = "rides") {

        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.AndrewHuggins.RideTrackr")
        let dbPath = containerURL?.appendingPathComponent("\(fileName).sqlite")

        // create an fmdatabase from filepath
        let db = FMDatabase(url: dbPath)

        // open connection to database
        guard db.open() else {
            fatalError("Unable to open database")
        }

        // intial table creation
        do {
            try db.executeUpdate(Self.getDBSchema(), values: nil)

        } catch {
            fatalError("cannot execute table creation query")
        }

        self.db = db

        self.rides = getAllRides()
    }

    // MARK: - DB Queries

    /// Gets all rides stored in the database
    /// - Returns: An array of ``Ride`` objects that represent all the rides stored in the application
    func getAllRides() -> [Ride] {

        let query = "SELECT * FROM Rides ORDER BY rideDate DESC"

        var rides = [Ride]()

        do {
            let result = try db.executeQuery(query, values: nil)

            while result.next() {
                if let ride = Ride(from: result) {
                    rides.append(ride)
                }
            }
        } catch {
            fatalError("Problem getting rides: \(error.localizedDescription)")
        }
        return rides
    }


    /// Inserts a ride into the database if it is not already in it
    /// - Parameter ride: The ride to insert
    func insertRide(_ ride: Ride) {

        // check if the ride is already in the rides list
        if self.rides.contains(where: { exsistingRide in exsistingRide.rideDate.formatted() == ride.rideDate.formatted() }) {
            self.rides.sort { $0.rideDate > $1.rideDate }
            return
        }

        let sqlQuery = """
        INSERT INTO Rides("id","heartRate","speed","distance","activeEnergy","altitudeGained","rideDate","duration","temperature","humidity","effortScore","routeData","hrSamples","altitdueSamples","speedSamples") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
        """

        do {

            try db.executeUpdate(sqlQuery, values: ride.getDBValues())

            DispatchQueue.main.async {
                self.rides.append(ride)

                TrendManager.shared.distanceTrends.append(TrendItem(value: ride.distance, date: ride.rideDate))
                TrendManager.shared.energyTrends.append(TrendItem(value: ride.activeEnergy, date: ride.rideDate))
                TrendManager.shared.heartRateTrends.append(TrendItem(value: ride.heartRate, date: ride.rideDate))
                TrendManager.shared.speedTrends.append(TrendItem(value: ride.speed, date: ride.rideDate))
            }

        } catch {
            fatalError("Error encoding data: \(error)")
        }

        DispatchQueue.main.async {
            self.rides.sort { $0.rideDate > $1.rideDate }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    public func updateRide(_ ride: Ride) async -> Ride {

        let updatedRide = await HKManager.shared.getRides(numRides: 1, startDate: ride.rideDate.addingTimeInterval(-60), endDate: .now).first!

        let index = self.rides.firstIndex(where: { abs($0.rideDate.timeIntervalSince(updatedRide.rideDate)) < 1 })!

        let sqlQuery = """
        UPDATE Rides
        SET 
            heartRate = ?,
            speed = ?,
            distance = ?,
            activeEnergy = ?,
            altitudeGained = ?,
            duration = ?,
            temperature = ?,
            humidity = ?,
            effortScore = ?,
            routeData = ?,
            hrSamples = ?,
            altitdueSamples = ?,
            speedSamples = ?
        WHERE ABS((JULIANDAY(rideDate) - JULIANDAY(?)) * 86400) <= 5
        """
//        let sqlQuery = """
//       UPDATE Rides
//       SET
//       heartRate = ?,
//       speed = ?,
//       distance = ?,
//       activeEnergy = ?,
//       altitudeGained = ?,
//       duration = ?,
//       temperature = ?,
//       humidity = ?,
//       effortScore = ?,
//       routeData = ?,
//       hrSamples = ?,
//       altitdueSamples = ?,
//       speedSamples = ?
//       WHERE rideDate = ?
//       """
//
        do {
            try db.executeUpdate(sqlQuery, values: updatedRide.getDBValues())

            DispatchQueue.main.async {

                self.rides[index] = updatedRide

            }

        } catch {
            fatalError("Error encoding data: \(error)")
        }

        return updatedRide
    }

    // MARK: - Helpers

    /// Reads the database schema file and returns the database schema string
    /// - Returns: The database schema string
    private static func getDBSchema() -> String {

        var schemaString: String = ""

        if let filePath = Bundle.main.path(forResource: "mainSchema", ofType: "sql") {
            do {
                schemaString = try String(contentsOfFile: filePath, encoding: .utf8)

            } catch {
                print("Error reading schema file: \(error)")
            }
        } else {
            print("schema.sql file not found")
        }

        return schemaString
    }

    /// checks the healthstore for new rides that have happened in the last week
    public func refreshRides() {
        HKManager.shared.queryingHealthKit = true

        DispatchQueue.main.async {
            Task {

                let syncedRides = await HKManager.shared.getRides(getAllRides: true, startDate: .sevenDaysAgo, endDate: .now)
                print(syncedRides.count)
                for ride in syncedRides {

                    self.insertRide(ride)
                }

                HKManager.shared.queryingHealthKit = false
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    /// empties the database and rides array, resyncs with healthkit, and reinserts all rides back into the database
    public func reyncData() {
        print("Refreshing rides")
        HKManager.shared.queryingHealthKit = true

        // 1. empty database
        let queryString = "DELETE FROM Rides;"

        do {
            try db.executeUpdate(queryString, values: nil)

        } catch {
            print("Error deleting all rides: \(error.localizedDescription)")

            return
        }

        // 2. empty rides array
        self.rides.removeAll()

        // 3. get all rides again
        DispatchQueue.main.async {
            Task {

                let syncedRides = await HKManager.shared.getRides(getAllRides: true)
                print(syncedRides.count)

                // 4. reinsert all rides
                for ride in syncedRides {

                    self.insertRide(ride)
                }
                HKManager.shared.queryingHealthKit = false
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

}

class PreviewDataManager: DataManager {

    init () {
        super.init()
        self.rides = previewRideArray
    }

    override func getAllRides() -> [Ride] {
        return previewRideArray
    }

}
