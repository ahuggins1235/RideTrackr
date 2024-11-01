//
//  GoalEntry.swift
//  RideTrackrWidgetExtension
//
//  Created by Andrew Huggins on 1/11/2024.
//

import WidgetKit

struct GoalEntry: TimelineEntry {
    
    let date: Date
    let distanceGoal: Goal
    let energyGoal: Goal
    let durationGoal: Goal
    let altitudeGoal: Goal
}
