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
    
    @AppStorage("distanceTarget") static var distanceTarget: Double = 100
    @AppStorage("energyTarget") static var energyTarget: Double = 5000
    @AppStorage("durationTarget") static var durationTarget: Double = 500
    @AppStorage("altiudeTarget") static var altiudeTarget: Double = 300
    
    init() {
        updateProgress()
    }
    
    func updateProgress() {
        
        self.distanceGoal.current = 0
        self.energyGoal.current = 0
        self.durationGoal.current = 0
        self.altiudeGainedGoal.current = 0
        
        
        let rides = DataManager.shared.rides.filter { ride in
            
            
            let dateFilter: DateInterval
            
            switch self.goalTimeFrame {
                case .SevenDays:
                    dateFilter = DateInterval(start: .startOfWeekMonday!, end: .now)
                case .Month:
                    dateFilter = DateInterval(start: .startOfMonth, end: .now)
                case .Year:
                    dateFilter = DateInterval(start: .startOfYear, end: .now)
            }
            
            let calendar = Calendar.current
            
            // Start date at the beginning of the day
            let startOfDay = calendar.startOfDay(for: dateFilter.start)
            
            // End date at the end of the day
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: dateFilter.end))!
            
            let interval = DateInterval(start: startOfDay, end: endOfDay)
            
            return interval.contains(ride.rideDate)
        }
        
        for ride in rides {
            self.distanceGoal.current += ride.distance
            self.energyGoal.current += ride.activeEnergy
            self.durationGoal.current += (ride.duration / 60)
            self.altiudeGainedGoal.current += ride.altitudeGained
        }
    }
}

class PreviewGoalManager: GoalManager {
    
    override init() {
        super.init()
        self.altiudeGainedGoal.current = 200
        self.energyGoal.current = 2000
        self.distanceGoal.current = 50
        self.durationGoal.current = 200
    }
    
}
