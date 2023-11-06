//
//  RideTrackrApp.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData

@main
struct RideTrackrApp: App {
    
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
    
//    @StateObject var trendsManager =  TrendManager()
//    @StateObject var healthManager = HealthManager()
//    @StateObject var navigationManager = NavigationManager()
//    @StateObject var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TrendManager())
                .environmentObject(HealthManager())
                .environmentObject(NavigationManager())
                .environmentObject(SettingsManager())
        }
        .modelContainer(sharedModelContainer)
    }
}
