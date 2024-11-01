//
//  SmallGoalView.swift
//  RideTrackrWidgetExtension
//
//  Created by Andrew Huggins on 1/11/2024.
//

import SwiftUI
    

struct SmallGoalView: View {

    @ObservedObject var settingsManager: SettingsManager = .shared
    var entry: GoalEntry

    var body: some View {
        VStack {

            VStack(spacing: 10) {
                GoalWidgetGaugeView(goal: entry.distanceGoal, unit: settingsManager.distanceUnit.distAbr)
                GoalWidgetGaugeView(goal: entry.energyGoal, unit: settingsManager.energyUnit.abr)
                GoalWidgetGaugeView(goal: entry.durationGoal, unit: "mins")
                GoalWidgetGaugeView(goal: entry.altitudeGoal, unit: settingsManager.distanceUnit.smallDistanceAbr)
            }
                .padding(.horizontal)
        }
            .foregroundStyle(.white)
            .padding(.vertical)
            .background(.red.gradient)
            .widgetURL(URL(string: "ridetrackr://goal/0"))

    }


}

#Preview {
    SmallGoalView(entry: GoalEntry(date: Date(), distanceGoal: .defaultDistance, energyGoal: .defaultEnergy, durationGoal: .defaultDuration, altitudeGoal: .defaultAltiudeGained))
}

struct GoalWidgetGaugeView: View {

    let goal: Goal
    let unit: String

    var body: some View {

        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: goal.goalType.icon)
                
                Spacer()
                
                Text("\(goal.currentDisplay) \(unit)")
                    .scaledToFill()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)


            }
                .bold()
            HStack {
                GeometryReader { geo in
                    
                    
                    ZStack(alignment: .leading) {
                        
                        Capsule()
                            .fill(.secondary)
                            .frame(width: geo.size.width, height: 5)
                        Capsule()
                            .fill(goal.goalType.color)
                            .frame(width: getIndicatorWidth(geometry: geo, progress: goal.progress), height: 5)
                    }
                }
                if goal.current >= goal.target {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
        }
    }
    func getIndicatorWidth(geometry: GeometryProxy, progress: Double) -> CGFloat {
        return max(min((geometry.size.width * CGFloat(progress)), geometry.size.width), 20)
    }
}
