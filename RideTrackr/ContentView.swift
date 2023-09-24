//
//  ContentView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        VStack {
            RideTrackrTabView()
        }.overlay {
            if healthManager.queryingHealthKit {
                ZStack {
                    
                    Rectangle()
                        .fill(.background)
                        .ignoresSafeArea()

                    
                    ProgressView {
                        Text("Loading")
                        
                    }
                    .foregroundStyle(.primary)
                    
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
