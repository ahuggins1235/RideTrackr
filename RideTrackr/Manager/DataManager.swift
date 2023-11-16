//
//  DataManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 16/11/2023.
//

import Foundation
import SwiftData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    let container: ModelContainer
    
    private init() {
        
        let schema = Schema([
            Ride.self,
            StatSample.self,
            PersistentLocation.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
