//
//  File.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import Foundation
import SwiftUI

/// Holds all the data for the user cycling trends
class TrendManager: ObservableObject {
    
    
    /// An array of `TrendItem` objects representing the user's heart rate trends over time.
    @Published var heartRateTrends: [TrendItem] = []
    /// An array of `TrendItem` objects representing the user's distance trends over time.
    @Published var distanceTrends: [TrendItem] = []
    /// An array of `TrendItem` objects representing the user's speed trends over time.
    @Published var speedTrends: [TrendItem] = []
    /// An array of `TrendItem` objects representing the user's energy trends over time.
    @Published var energyTrends: [TrendItem] = []
    ///
    @AppStorage("timeFrame") var timeFrame: TrendTimeFrame = .Month
    
    
    var currentAverageHeartRate: Double {
        return calculateCurrentAverage(.HeartRate)
    }
    
    var currentAverageSpeed: Double {
        return calculateCurrentAverage(.Speed)
    }
    
    var currentAverageDistance: Double {
        return calculateCurrentAverage(.Distance)
    }
    
    var currentAverageEnergy: Double {
        return calculateCurrentAverage(.Energy)
    }

    
    
    /// Calculates the current average value for a given trend type based on the currently selected time frame
    /// - Parameter trendType: The trend type to calculate the average for
    /// - Returns: The current average value for a given trend type
    func calculateCurrentAverage(_ trendType: TrendType) -> Double {
        
        var list: [TrendItem]
        
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
        
        let filteredList = list.filter { $0.date > timeFrame.dateOffset }
//        let filteredList = list
        
        let sum = filteredList.reduce(0) { (currentSum, nextNumber) in
            return currentSum + nextNumber.value
        }
        
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
        
        // Initialize an empty list to store the results
        var averages: [Double] = []
        // Loop over the list from index 0 to index n-2, where n is the length of the list
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


struct TrendItem: Identifiable {
    
    var id = UUID()
    var value: Double
    var date: Date
    var animate: Bool = false
    
}

struct sampleTrendMaker {
    
    static func generateSampleData() -> [TrendItem] {
        let currentDate = Date()
        let calendar = Calendar.current
        var data: [TrendItem] = []
        
        // Start from the date one month ago
        if let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            
            // Generate trend items for each day over the past month
            var date = oneMonthAgo
            
            while date <= currentDate {
                
                // Generate a random heart rate value for the current date
                let randomValue = Double.random(in: 60...100)
                
                // Create a trend item with the current date and random value
                let trendItem = TrendItem(value: randomValue, date: date)
                
                // Append the trend item to the array
                data.append(trendItem)
                
                // Move to the next day
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
        }
        
        return data

    }
}
