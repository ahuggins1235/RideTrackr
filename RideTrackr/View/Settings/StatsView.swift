//
//  StatsView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 30/10/2024.
//

import SwiftUI

struct StatsView: View {
    
    @State var timeFrame: StatsDateFilter = .allTime
    @ObservedObject var dataManager: DataManager = .shared
    @ObservedObject var settingsManager: SettingsManager = .shared
    
    var filteredRides: [Ride] {
        
        var rides = dataManager.rides
        
        rides = rides.filter { ride in
            
            
            let dateFilter = timeFrame.interval
            
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
        return rides
        
    }
    
    var totalRides: String {
        return String(filteredRides.count)
    }
    
    var totalDistance: String {
        
        let conversion = settingsManager.distanceUnit.distanceConversion
        let unit = settingsManager.distanceUnit.distAbr
        
        return "\((filteredRides.reduce(0) { $0 + $1.distance * conversion }).round(to: 2)) \(unit)"
    }
    
    var totalEnergy: String {
        
        let conversion = settingsManager.energyUnit.conversionValue
        let unit = settingsManager.energyUnit.abr
        
        return "\(Int(filteredRides.reduce(0) { $0 + $1.activeEnergy * conversion })) \(unit)"
    }
    
    var totalDuration: String {
        
        let unit = "mins"
        
        return "\(Int(filteredRides.reduce(0) { $0 + $1.duration })) \(unit)"
    }
    
    var totalAltitude: String {
        
        let conversion = settingsManager.distanceUnit.smallDistanceConversion
        let unit = settingsManager.distanceUnit.smallDistanceAbr
        
        return "\((filteredRides.reduce(0) { $0 + $1.altitudeGained * conversion }).round(to: 1)) \(unit)"
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading) {
                
                StatsTimeFramePicker(timeFrame: $timeFrame)
                    .padding(.horizontal)
                    .zIndex(1)
                
                Divider()
                VStack(spacing: 10) {
                    HStack {
                        Text("Total Rides:")
                            .bold()
                        Spacer()
                        Text(totalRides)
                    }
                    HStack {
                        Text("Total Distance:")
                            .bold()
                        Spacer()
                        Text(totalDistance)
                    }
                    HStack {
                        Text("Total Energy Burned:")
                            .bold()
                        Spacer()
                        Text(totalEnergy)
                    }
                    HStack {
                        Text("Total Duration:")
                            .bold()
                        Spacer()
                        Text(totalDuration)
                    }
                    HStack {
                        Text("Total Altitude Gained:")
                            .bold()
                        Spacer()
                        Text(totalAltitude)
                    }
                }
                .contentTransition(.numericText())
                .padding(.horizontal)
                
                Divider()
                
                Spacer()
            }
            .navigationTitle("Stats")
            
        }
        
    }
}

#Preview {
    StatsView(dataManager: PreviewDataManager())
}

struct StatsTimeFramePicker: View {
    
    @Binding var timeFrame: StatsDateFilter
    @State var expanded: Bool = false
    
    var body: some View {
        
        HStack {
            
            Text("\(timeFrame.rawValue)")
            
            Label("Drop Down Arrow", systemImage: "chevron.down")
                .rotationEffect(Angle(degrees: expanded ? -180 : 0))
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
            
        }
        .bold()
        .frame(alignment: .leading)
        .padding(9)
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
        .sensoryFeedback(.impact, trigger: expanded)
        .overlay(alignment: .leading) {
            if expanded {
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(StatsDateFilter.allCases) { timeFrame in
                        VStack {
                            Text(timeFrame.rawValue)
                                .onTapGesture {
                                    withAnimation {
                                        self.timeFrame = timeFrame
                                        expanded.toggle()
                                    }
                                }
                            Divider()
                        }
                    }
                }
                .frame(width: 100, alignment: .leading)
                .bold()
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThickMaterial)
                }
                .offset(y: 120)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .font(.title3)
    }
}


enum StatsDateFilter: String, CaseIterable, Identifiable {
    
    case allTime = "All Time"
    case week = "Week"
    case oneMonth = "Month"
    case year = "Year"
    
    var id: StatsDateFilter { self }
    
    var interval: DateInterval {
        
        switch self {
                
            case .allTime:
                return DateInterval(start: .distantPast, end: Date())
                
            case .week:
                let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                return DateInterval(start: startDate, end: Date())
                
            case .oneMonth:
                let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                return DateInterval(start: startDate, end: Date())
                
            case .year:
                let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
                return DateInterval(start: startDate, end: Date())
        }
    }
}
