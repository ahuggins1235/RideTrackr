//
//  GoalManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 23/10/2024.
//

import Foundation
import SwiftUI

class GoalManager: ObservableObject {
    
    public static let shared = GoalManager()
    @AppStorage("goalTimeFrame") var goalTimeFrame: TimeFrame = .SevenDays
    @AppStorage("distanceGoal") var distanceGoal: Goal = .defaultDistance
    @AppStorage("energyGoal") var energyGoal: Goal = .defaultEnergy
    @AppStorage("durationGoal") var durationGoal: Goal = .defaultDuration
    @AppStorage("altiudeGainedGoal") var altiudeGainedGoal: Goal = .defaultAltiudeGained
}
