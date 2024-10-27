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
    @State var completed: Bool = false

    var body: some View {

        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                
                Label(goal.title, systemImage: goal.goalType.icon)

                Spacer()

                Text("\(goal.currentDisplay)/\(goal.targetDisplay) \(goal.goalType.unit)")
            }
                .foregroundStyle(foregroundColour)
                .bold()
                .opacity(0.75)

            Spacer()
            
            HStack {
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .foregroundStyle(.tertiary)
                        Capsule()
                            .foregroundStyle(foregroundColour)
                            .frame(width: getIndicatorWidth(geometry: geometry))
                        
                    }
                }
                
                if goal.current >= goal.target {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(foregroundColour)
                }
            }
            .brightness(completed ? 0.2 : 0)
            .scaleEffect(completed ? 1.1 : 1)
            .animation(.easeInOut(duration: 0.5), value: completed)
                .frame(height: 20)

        }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .onTapGesture {
                withAnimation(.easeInOut) {
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
                if goal.current >= goal.target {
                    completed = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        completed = false
                    }
                }
            }
                
                    
                
        }
            .sensoryFeedback(.impact, trigger: selectedGoal)
    }
    
    func getIndicatorWidth(geometry: GeometryProxy) -> CGFloat {
        return animated ? max(min((geometry.size.width * CGFloat(goal.progress)), geometry.size.width), 20) : 0
    }
}

#Preview {
    @Previewable @State var previewGoal: Goal = Goal(id: UUID(), title: "Energy", target: 5000, current: 2000, goalType: .Energy)
    GoalProgressView(goal: $previewGoal, selectedGoal: .constant(.none))
}
