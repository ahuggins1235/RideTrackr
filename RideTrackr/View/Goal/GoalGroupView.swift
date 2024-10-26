//
//  GoalGroupView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//

import SwiftUI

struct GoalGroupView: View {
    
    @Binding var selectedGoal: GoalType?
    @ObservedObject var goalManager: GoalManager = .shared
    
    var body: some View {
        VStack(spacing: 10) {
            if goalManager.energyGoal.enabled {
                GoalProgressView(goal: $goalManager.energyGoal, selectedGoal: $selectedGoal)
            }
            if goalManager.distanceGoal.enabled {
                GoalProgressView(goal: $goalManager.distanceGoal, selectedGoal: $selectedGoal)
            }
            if goalManager.altiudeGainedGoal.enabled {
                GoalProgressView(goal: $goalManager.altiudeGainedGoal, selectedGoal: $selectedGoal)
            }
            if goalManager.durationGoal.enabled {
                GoalProgressView(goal: $goalManager.durationGoal, selectedGoal: $selectedGoal)
            }
        }
        .padding()
//        .background(.cardBackground)
//        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
}

#Preview {
    
    @Previewable @State var selectedGoal: GoalType?
    
    GoalGroupView(selectedGoal: $selectedGoal)
}
