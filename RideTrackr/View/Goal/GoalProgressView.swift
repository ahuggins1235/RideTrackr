//
//  GoalProgressView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//

import SwiftUI

struct GoalProgressView: View {

    @Binding var goal: Goal
    @Binding var selectedGoal: GoalType?
    var foregroundColour: Color {
        if let selectedGoal {
            return selectedGoal == goal.goalType ? goal.goalType.color : .secondary
        }

        return goal.goalType.color
    }

    @State var animated: Bool = false

    var body: some View {

        VStack {
            HStack {
                Label(goal.title, systemImage: goal.goalType.icon)

                Spacer()

                Text("\(animated ? goal.currentDisplay : "0")/\(goal.targetDisplay) \(goal.goalType.unit)")

            }
            .foregroundStyle(foregroundColour)
                .contentTransition(.numericText())
                .bold()
                .opacity(0.75)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .foregroundStyle(.tertiary)
                    Capsule()
                        .foregroundStyle(foregroundColour)
                        .frame(width: animated ? (geometry.size.width * CGFloat(goal.progress)) : 0) 
                        
                }
                    .frame(height: 20)
            }

        }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    if selectedGoal == goal.goalType {
                        selectedGoal = .none
                    } else {
                        selectedGoal = goal.goalType
                    }
                }
        }
            .onAppear {
            withAnimation {
                animated = true
            }
        }
            .sensoryFeedback(.impact, trigger: selectedGoal)
    }
}

#Preview {
    @Previewable @State var previewGoal: Goal = Goal(id: UUID(), title: "Energy", target: 5000, current: 2000, goalType: .Energy)
    GoalProgressView(goal: $previewGoal, selectedGoal: .constant(.none))
}
