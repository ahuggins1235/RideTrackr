//
//  DataManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 16/11/2023.
//

import Foundation
import FMDB

final class DataManager: ObservableObject {
    
    private let db: FMDatabase
    
    public static let shared = DataManager()
    @Published var rides = [Ride]()
    
    init(fileName: String = "rides") {
        
        // get filepath of the SQlite DB file
        let fileURL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
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
            print("Tables created successfully")
            
//            let result  = try db.executeQuery("SELECT name FROM sqlite_master WHERE type='table';", values: nil)
//            let test = result.resultDictionary?.count
//            print(test)
//            while result.next() {
//                print(result.string(forColumn: "name"))
//            }
//            
        } catch {
            fatalError("cannot execute table creation query")
        }
        
        self.db = db
        
    }
    
    // MARK: - DB Queries
    func getAllRides() ->[Ride] {
        
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
    
    func insertRide(_ ride: Ride) {
        
        let sqlQuery = """
        INSERT INTO Rides("id","heartRate","speed","distance","activeEnergy","altitudeGained","rideDate","duration","temperature","routeData","hrSamples","altitudeSamples","speedSamples") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);
        """
        
        do {
            let routeDataData = try JSONEncoder().encode(ride.routeData)
            let routeDataBlob = NSData(data: routeDataData)
            
            let hrSamplesData = try JSONEncoder().encode(ride.hrSamples)
            let hrSamplesBlob = NSData(data: hrSamplesData)
            
            let altitudeSamplesData = try JSONEncoder().encode(ride.altitudeGained)
            let altitudeSamplesBlob = NSData(data: altitudeSamplesData)
            
            let speedSamplesData = try JSONEncoder().encode(ride.speedSamples)
            let speedSamplesBlob = NSData(data: speedSamplesData)
            
            let values: [Any] = [
                ride.id,
                ride.heartRate,
                ride.speed,
                ride.distance,
                ride.activeEnergy,
                ride.altitudeGained,
                ride.rideDate,
                ride.duration,
                ride.temperature!,
                routeDataBlob,
                hrSamplesBlob,
                altitudeSamplesBlob,
                speedSamplesBlob
            ]
            
            try db.executeUpdate(sqlQuery, values: values)
            
            rides.append(ride)
            
        } catch {
            fatalError("Error encoding data: \(error)")
        }
       
        
    }

    
    // MARK: - Helpers
    private static func getDBSchema() -> String {
        
        var schemaString = ""
        
        if let filePath = Bundle.main.path(forResource: "mainSchema", ofType: "sql") {
            do {
                schemaString = try String(contentsOfFile: filePath, encoding: .utf8)
                
            } catch {
                print("Error reading schema file: \(error)")
            }
        } else {
            print("schema.sql file not found")
            return ""
        }

        return "CREATE TABLE IF NOT EXISTS \"Rides\" (\"id\"    TEXT,\"heartRate\"    NUMERIC,\"speed\"    NUMERIC,\"distance\"    NUMERIC,\"activeEnergy\"    NUMERIC,\"altitudeGained\"    NUMERIC,\"rideDate\"    TEXT,\"duration\"    NUMERIC,\"temperature\"    NUMERIC,\"routeData\"    BLOB,\"hrSamples\"    BLOB,\"altitudeSamples\"    BLOB,\"speedSamples\" BLOB,PRIMARY KEY(\"id\"))"
    }
    
    
}
