//
//  SettingsView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import Foundation

struct SettingsView: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    
    var body: some View {

        NavigationStack {
            List {

                Section("Units") {
                    Picker("Distance", selection: $settingsManager.distanceUnit) {
                        
                        ForEach(DistanceUnit.allCases) { unit in
                            Text("\(unit.rawValue)  (\(unit.abr))").tag(unit.rawValue)
                        }
                    }
                    
                    Picker("Energy", selection: $settingsManager.energyUnit) {
                        
                        ForEach(EnergyUnit.allCases) { unit in
                            Text("\(unit.rawValue)  (\(unit.abr))").tag(unit.rawValue)
                        }
                        
                    }
                }
            }.navigationTitle("Settings")
        }

    }
}

#Preview {
    SettingsView().environmentObject(SettingsManager())
}


