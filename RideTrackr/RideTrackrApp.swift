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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ColorSchemeWrapper {
                ContentView()
            }
        }
    }
}

struct ColorSchemeWrapper<Content: View>: View {
    @ObservedObject private var settingsManager: SettingsManager = .shared
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let content: () -> Content
    
    var body: some View {
        content()
            .preferredColorScheme(getColorScheme())
    }
    
    private func getColorScheme() -> ColorScheme? {
        switch settingsManager.theme {
            case .System:
                print(colorScheme)
                return colorScheme
            case .Dark:
                return .dark
            case .Light:
                return .light
        }
    }
}
//struct RideTrackrApp: App {
//    
//    @ObservedObject private var settingsManager: SettingsManager = .shared
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @Environment(\.colorScheme) var colorScheme: ColorScheme
//
//    var body: some Scene {
//        WindowGroup {
//            
//                ContentView()
////                    .preferredColorScheme( settingsManager.theme == .System ? .none : ( settingsManager.theme == .Dark ? .dark : .light ) )
//                .preferredColorScheme( getColourScheme() )
//            
//        }
//    }
//    
//    
//    /// Gets the correct colour scheme depending on the user's choice
//    /// - Returns: The correct colour scheme according to the user's choice
//    func getColourScheme() -> ColorScheme {
//        
//        if settingsManager.theme != .System {
//            return settingsManager.theme == .Dark ? .dark : .light
//        }
//        print(colorScheme)
//        
//        return colorScheme == .dark ? .dark : .light
//    }
//}
