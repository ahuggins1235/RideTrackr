//
//  RideTrackrApp.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData
import CoreData

@main
struct RideTrackrApp: App {
    
    @StateObject var dataManager = DataManager.shared
    @StateObject var healthManager = HealthManager()
    
    init() {
        ValueTransformer.setValueTransformer(CLLocationArrayTransformer(), forName: NSValueTransformerName(rawValue: String(describing: CLLocationArrayTransformer.self)))
    }
    
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Ride.self,
            StatSample.self,
            PersistentLocation.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TrendManager())
                .environmentObject(healthManager)
                .environmentObject(NavigationManager())
                .environmentObject(SettingsManager())
        }
        .modelContainer(dataManager.container)
    }
}
