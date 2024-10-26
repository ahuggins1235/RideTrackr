//
//  GoalEditView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 26/10/2024.
//

import SwiftUI

struct GoalEditView: View {
    
    @ObservedObject var goalManager: GoalManager = .shared
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Time") {
                    
                    Picker("Goal Timeframe", selection: goalManager.$goalTimeFrame) {
                        ForEach(TimeFrame.allCases) {timeFrame in
                            Text(timeFrame.rawValue)
                        }
                    }
                }
                
                Section("Goals") {
                    
//                    LabeledContent("Energy") {
                        GoalStepperView(
                            value: $goalManager.energyGoal.target,
                            increment: 100,
                            color: .energy,
                            isEnabled: $goalManager.energyGoal.enabled,
                            title: "Energy"
                        )
                            .foregroundStyle(.primary)
//                    }
                    .bold()
                    
//                    LabeledContent("Distance") {
                        GoalStepperView(
                            value: $goalManager.distanceGoal.target,
                            increment: 10,
                            color: .distance,
                            isEnabled: $goalManager.distanceGoal.enabled,
                            title: "Distance"
                        )
                            .foregroundStyle(.primary)
//                    }
                    .bold()
                    
//                    LabeledContent("Altiude") {
                        GoalStepperView(
                            value: $goalManager.altiudeGainedGoal.target,
                            increment: 10,
                            color: .altitude,
                            isEnabled: $goalManager.altiudeGainedGoal.enabled,
                            title: "Altiude"
                        )
                            .foregroundStyle(.primary)
//                    }
                    .bold()
                    
//                    LabeledContent("Duration") {
                        GoalStepperView(
                            value: $goalManager.durationGoal.target,
                            increment: 100,
                            color: .duration,
                            isEnabled: $goalManager.durationGoal.enabled,
                            title: "Duration"
                        )
                            .foregroundStyle(.primary)
                    }
                    .bold()
//                }
                
            }
            .toolbar {
                Button("Done") {
                    isPresented.toggle()
                }
            }
        }
    }
}

#Preview {
    GoalEditView(isPresented: .constant(true))
}
