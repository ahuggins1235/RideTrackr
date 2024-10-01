//
//  TrendManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import Foundation
import SwiftUI

/// Holds all the data for the user cycling trends
class TrendManager: ObservableObject {
    
    // MARK: - properties
    
    public static var shared = TrendManager()
    
    /// An array of `TrendItem` objects representing the user's heart rate trends over time.
    @Published var heartRateTrends: [TrendItem] = []
    /// An array of `TrendItem` objects representing the user's distance trends over time.
    @Published var distanceTrends: [TrendItem] = []
    /// An array of `TrendItem` objects representing the user's speed trends over time.
    @Published var speedTrends: [TrendItem] = []
    /// An array of `TrendItem` objects representing the user's energy trends over time.
    @Published var energyTrends: [TrendItem] = []
    /// the current trends timeframe that the user is viewing
    @AppStorage("timeFrame") var timeFrame: TrendTimeFrame = .Month
    
    
    /// Represents the current rolling average heart rate of the user.
    var currentAverageHeartRate: Double {
        return calculateCurrentAverage(.HeartRate)
    }
    
    /// Represents the current rolling average speed of the user.
    var currentAverageSpeed: Double {
        return calculateCurrentAverage(.Speed)
    }
    
    /// Represents the current rolling average distance traveled by the user.
    var currentAverageDistance: Double {
        return calculateCurrentAverage(.Distance)
    }
    
    /// Represents the current rolling average energy expenditure of the user.
    var currentAverageEnergy: Double {
        return calculateCurrentAverage(.Energy)
    }


    // MARK: - methods
    
    /// Calculates the current average value for a given trend type based on the currently selected time frame
    /// - Parameter trendType: The trend type to calculate the average for
    /// - Returns: The current average value for a given trend type
    func calculateCurrentAverage(_ trendType: TrendType) -> Double {
        
        var list: [TrendItem]
        
        // get the correct list
        switch trendType {
            case .HeartRate:
                list = self.heartRateTrends
            case .Speed:
                list = self.speedTrends
            case .Distance:
                list = self.distanceTrends
            case .Energy:
                list = self.energyTrends
        }
        
        // filter the list so that it only contains values within the current timeframe
//        let filteredList = list.filter { $0.date > timeFrame.dateOffset }
        let filteredList = list
        
        // calculate the sum of the list
        let sum = filteredList.reduce(0) { (currentSum, nextNumber) in
            return currentSum + nextNumber.value
        }
        
        // calulate average
        let average = sum / Double(filteredList.count)
        
        return average
    }
    
    /// Calculates how a given trend type has changed over the given time frame and returns a percentage that reflects that
    /// - Parameters:
    ///     - trendType: the type of stat to draw data from
    ///     - timeFrame: the time frame to narrow down the change from
    /// - Returns: how much the trend has changed expressed as  percentage of the overal whole
    func calculateTrendChange(trendType: TrendType, timeFrame: TrendTimeFrame) -> Double {
        
        var list: [TrendItem]
        
        // get the correct list
        switch trendType {
            case .HeartRate:
                list = self.heartRateTrends
            case .Speed:
                list = self.speedTrends
            case .Distance:
                list = self.distanceTrends
            case .Energy:
                list = self.energyTrends
        }
        
        // check if the list is empty and if it is return early
        if list.isEmpty {
            return 0.0
        }
        
        // filter the list by the given time frame
        list = list.filter {$0.date > timeFrame.dateOffset}
        
        var averages: [Double] = []
        
        
        for i in 0..<list.count - 1 {
        
            // Get the current value and the next value in the list
            let currentValue = list[i].value
            let nextValue = list[i + 1].value
            
            // Calculate the percentage change between them
            let change = (nextValue - currentValue) / currentValue * 100
            
            // Append the result to the result list
            averages.append(change)
        }

        let sum = averages.reduce(0, +)

        let average = (sum / Double(averages.count)).rounded()

        return average
        
        
    }
    
}



/// A struct representing a single data point for a trend over time.
struct TrendItem: Identifiable {

    var id = UUID()
    /// The value of the trend item.
    var value: Double
    /// The date associated with the trend item.
    var date: Date
    /// A Boolean value indicating whether the trend item should be animated.
    var animate: Bool = false
}

class PreviewTrendManager: TrendManager {
    
    override init() {
        
        let sampleTrendItem = TrendItem(value: 100, date: Date(), animate: false)
        
        super.init()
        
        self.heartRateTrends = [sampleTrendItem]
        self.distanceTrends = [sampleTrendItem]
        self.speedTrends = [sampleTrendItem]
        self.energyTrends = [sampleTrendItem]
    }
}
