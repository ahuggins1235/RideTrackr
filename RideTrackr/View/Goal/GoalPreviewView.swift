//
//  GoalPreviewView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 27/10/2024.
//

import SwiftUI

struct GoalPreviewView: View {

    @ObservedObject var goalManager: GoalManager = .shared

    var grids: [GridItem] = [
            .init(.flexible()),
            .init(.flexible())
    ]

    var body: some View {

        VStack {

            HStack {
                Text("This \(goalManager.goalTimeFrame.futureLabel)'s Goals")
                    .bold()
                    .font(.headline)
                
                Spacer()
                
                Text("Show more...")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.accent)
            .unredacted()

            LazyVGrid(columns: grids) {
                
                GoalGaugeView(goal: $goalManager.distanceGoal)
                GoalGaugeView(goal: $goalManager.energyGoal)
                GoalGaugeView(goal: $goalManager.durationGoal)
                GoalGaugeView(goal: $goalManager.altiudeGainedGoal)
            }
                .padding()
                .background(.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
            .contentShape(Rectangle())
            .onTapGesture {
            NavigationManager.shared.selectedTab = .Goals
        }
    }
}

#Preview {
    GoalPreviewView(goalManager: PreviewGoalManager())
        .padding()
        .background(Color(.systemGroupedBackground))
}

struct GoalGaugeView: View {

    @Binding var goal: Goal

    var body: some View {

        VStack {

            Label(goal.title, systemImage: goal.goalType.icon)
                .foregroundStyle(goal.goalType.color)
                .bold()
                .padding(.vertical, 5)

            Gauge(value: min(goal.current, goal.target), in: 0...goal.target) {


            }
                .gaugeStyle(.linearCapacity)
                .tint(goal.goalType.color)

            Text("\(goal.currentDisplay) \(goal.goalType.unit)")
                .lineLimit(1)
                .bold()
        }

    }
}
