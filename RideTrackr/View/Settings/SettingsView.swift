//
//  SettingsView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import Foundation

@MainActor
struct SettingsView: View {
    
    @ObservedObject var settingsManager: SettingsManager = .shared
    @ObservedObject var dataManager: DataManager = .shared
    @State var showResyncAlert = false
    
    var body: some View {

        NavigationStack {
            List {

                Section("Units") {
                    Picker("Distance", selection: $settingsManager.distanceUnit) {
                        
                        ForEach(DistanceUnit.allCases) { unit in
                            Text("\(unit.rawValue)  (\(unit.distAbr)/\(unit.smallDistanceAbr))").tag(unit.rawValue)
                        }
                    }
                    
                    Picker("Energy", selection: $settingsManager.energyUnit) {
                        
                        ForEach(EnergyUnit.allCases) { unit in
                            Text("\(unit.rawValue)  (\(unit.abr))").tag(unit.rawValue)
                        }
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $settingsManager.theme) {
                        
                        ForEach(ColorSchemeChoice.allCases) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                }
                
                Section("Data") {
                    
                    HStack {
                        Button("Resync Data With Apple Health") {
                            if HKManager.shared.queryingHealthKit { return }
                            showResyncAlert.toggle()
                        }
                        .alert("Resync With Apple Health", isPresented: $showResyncAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Sync") {
                                DataManager.shared.reyncData()
                            }
                        } message: {
                            Text("This will reset RideTrackr's database and resync it with Apple Health. Are you sure?")
                        }
                        
                        Spacer()
                        
                        if HKManager.shared.queryingHealthKit {
                            ProgressView()
                        }
                        
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}


