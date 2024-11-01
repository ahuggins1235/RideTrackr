//
//  GoalProvider.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 1/11/2024.
//

import WidgetKit

struct GoalProvider: TimelineProvider {
    func placeholder(in context: Context) -> GoalEntry {
        GoalEntry(
            date: Date(),
            distanceGoal: .defaultDistance,
            energyGoal: .defaultEnergy,
            durationGoal: .defaultDuration,
            altitudeGoal: .defaultAltiudeGained
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GoalEntry) -> Void) {
        Task {
            completion(getGoalEntry())
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GoalEntry>) -> Void) {
        Task {
            let timeline = Timeline(entries: [getGoalEntry()], policy: .after(.now.advanced(by: 60 * 60 * 30)))
            completion(timeline)
        }
    }
    
    func getGoalEntry() -> GoalEntry {
        
        let goalManager = GoalManager.shared
        
        return GoalEntry(
            date: Date(),
            distanceGoal: goalManager.distanceGoal,
            energyGoal: goalManager.energyGoal,
            durationGoal: goalManager.durationGoal,
            altitudeGoal: goalManager.altiudeGainedGoal
        )
        
    }
}
