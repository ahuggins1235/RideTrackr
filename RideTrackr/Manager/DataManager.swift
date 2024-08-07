//
//  DataManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 16/11/2023.
//

import Foundation
import FMDB

class DataManager: ObservableObject {

    private let db: FMDatabase

    public static let shared = DataManager()

    @Published var rides = [Ride]()

    init(fileName: String = "rides") {

        // get filepath of the SQlite DB file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(fileName).sqlite")

        // create an fmdatabase from filepath
        let db = FMDatabase(url: fileURL)

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

        let query = "SELECT * FROM Rides"

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
        if self.rides.contains(where: { exsistingRide in exsistingRide.rideDate.formatted() == ride.rideDate.formatted()} ) {
            return
        }
        
        let sqlQuery = """
        INSERT INTO Rides("id","heartRate","speed","distance","activeEnergy","altitudeGained","rideDate","duration","temperature","routeData","hrSamples","altitdueSamples","speedSamples") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);
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


    }

    func updateOrInsertRide(_ ride: Ride) {

        let sqlQuery = """
            BEGIN TRANSACTION;
            
            -- Step 1: Update existing record if rideDate matches
            UPDATE Rides
            SET
                heartRate = ?,
                speed = ?,
                distance = ?,
                activeEnergy = ?,
                altitudeGained = ?,
                duration = ?,
                temperature = ?,
                routeData = ?,
                hrSamples = ?,
                altitdueSamples = ?,
                speedSamples = ?
            WHERE rideDate = ?;
            
            -- Step 2: Insert new record if no rows were updated
            INSERT INTO Rides (id, heartRate, speed, distance, activeEnergy, altitudeGained, rideDate, duration, temperature, routeData, hrSamples, altitdueSamples, speedSamples)
            SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            WHERE changes() = 0;
            
            COMMIT;
            """
        
        do {
            
            try db.executeQuery(sqlQuery, values: ride.getDBValues())
            
            if let index = self.rides.firstIndex(where: { $0.rideDate == ride.rideDate }) {
                self.rides[index] = ride
            } else {
                self.rides.append(ride)
            }
            
        } catch {
            fatalError("Error updating database \(error)")
        }

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
//        return "CREATE TABLE IF NOT EXISTS \"Rides\" (\"id\"    TEXT,\"heartRate\"    NUMERIC,\"speed\"    NUMERIC,\"distance\"    NUMERIC,\"activeEnergy\"    NUMERIC,\"altitudeGained\"    NUMERIC,\"rideDate\"    TEXT,\"duration\"    NUMERIC,\"temperature\"    NUMERIC,\"routeData\"    BLOB,\"hrSamples\"    BLOB,\"altitudeSamples\"    BLOB,\"speedSamples\" BLOB,PRIMARY KEY(\"id\"))"
    }

    
    ///
    public func refreshRides() {
        
        DispatchQueue.main.async {
            Task{
                HKManager.shared.queryingHealthKit = true
                let syncedRides = await HKManager.shared.getRides(numRides: 5)
                
                for ride in syncedRides {
                    
                    self.insertRide(ride)
                }
                
                HKManager.shared.queryingHealthKit = false
            }
        }
    }
    
    /// empties the database and rides array, resyncs with healthkit, and reinserts all rides back into the database
    public func reyncData() {
        
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
        print(rides.count)
        // 3. get all rides again
        DispatchQueue.main.async {
            Task {
                
                
                
                let syncedRides = await HKManager.shared.getRides(getAllRides: true)
                
                // 4. reinsert all rides
                for ride in syncedRides {
                    
                    self.insertRide(ride)
                }
                
                HKManager.shared.queryingHealthKit = false
            }
        }
    }
}

class PreviewDataManager: DataManager {
    
    override func getAllRides() -> [Ride] {
        return previewRideArray
    }
    
}
