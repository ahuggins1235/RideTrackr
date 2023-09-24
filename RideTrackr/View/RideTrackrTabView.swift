//
//  RideTrackrTabView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct RideTrackrTabView: View {
    
    // MARK: - Properties
//    @State private var selectedTab = "Home"
    @EnvironmentObject var navigationManager: NavigationManager
    
    // MARK: - Body
    var body: some View {
        
        TabView(selection: $navigationManager.selectedTab) {
            
            ForEach(ApplicationTab.allCases) { applicationTab in
                applicationTab.destination.tabItem { applicationTab.label }.tag(applicationTab.rawValue)
            }
        }
        .backgroundStyle(.ultraThinMaterial)
        .tabViewStyle(.automatic)
    }
}

// MARK: - Previews
#Preview {
    RideTrackrTabView()
        .environmentObject(NavigationManager())
}
