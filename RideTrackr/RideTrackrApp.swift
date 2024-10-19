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
    
    @ObservedObject private var settingsManager: SettingsManager = .shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .preferredColorScheme( settingsManager.theme == .System ? .none : ( settingsManager.theme == .Dark ? .dark : .light ) )
            //                .preferredColorScheme( getColourScheme() )
            
        }
    }
}
