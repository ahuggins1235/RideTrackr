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
@MainActor
struct RideTrackrApp: App {
    
    @ObservedObject private var settingsManager: SettingsManager = .shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme( settingsManager.theme == .System ? .none : ( settingsManager.theme == .Dark ? .dark : .light ) )
        }
    }
}
