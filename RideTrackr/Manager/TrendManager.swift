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
    
    @Published var heartRateTrends: [TrendItem] = []
    @Published var distanceTrends: [TrendItem] = []
    @Published var speedTrends: [TrendItem] = []
    @Published var energyTrends: [TrendItem] = []
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
    
    init() {
//        heartRateTrends = sampleTrendMaker.generateSampleData()
//        distanceTrends = sampleTrendMaker.generateSampleData()
//        speedTrends = sampleTrendMaker.generateSampleData()
//        energyTrends = sampleTrendMaker.generateSampleData()
//        heartRateTrends = [TrendItem(value: 1, date: Date()),TrendItem(value: 2, date: Date()),TrendItem(value: 3, date: Date()),TrendItem(value: 4, date: Date()),TrendItem(value: 5, date: Date())]
//        distanceTrends = []
//        speedTrends = []
//        energyTrends = []
    }
    
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
