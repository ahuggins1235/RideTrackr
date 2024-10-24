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
            GoalProgressView(goal: $goalManager.energyGoal, selectedGoal: $selectedGoal)
            GoalProgressView(goal: $goalManager.distanceGoal, selectedGoal: $selectedGoal)
            GoalProgressView(goal: $goalManager.altiudeGainedGoal, selectedGoal: $selectedGoal)
            GoalProgressView(goal: $goalManager.durationGoal, selectedGoal: $selectedGoal)
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
