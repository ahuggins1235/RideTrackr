//
//  GoalView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//

import SwiftUI

struct GoalView: View {

    @State var selectedGoal: GoalType?
    @ObservedObject var goalManager: GoalManager = .shared
    @ObservedObject var dataManager: DataManager = .shared
    @State var showEditSheet: Bool = false

    var rides: [Ride] {

        let rides = dataManager.rides.filter { ride in


            let dateFilter: DateInterval

            switch goalManager.goalTimeFrame {
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
        return rides
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack {

                    Text("This \(goalManager.goalTimeFrame.futureLabel)")
                        .padding([.leading, .top])
                        .bold()
                        .font(.title2)
                    Spacer()
                }
                
                GoalGroupView(selectedGoal: $selectedGoal)

                Divider()

                ZStack {
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()

                    ScrollView {
                        VStack {
                            ForEach(rides) { ride in
                                NavigationLink(value: ride) {
                                    GoalRowView(ride: ride, selectedGoal: $selectedGoal)
                                        
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                        .padding()
                }
                    .navigationDestination(for: Ride.self) { ride in
                    RideDetailView(ride: ride)
                }
            }
                .navigationTitle("Goals")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                Button("Edit") {
                    showEditSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            GoalEditView(isPresented: $showEditSheet)
                .presentationDetents([.medium])
        }
        
        .onChange(of: goalManager.goalTimeFrame) { oldValue, newValue in
            goalManager.updateProgress()
        }
        .onChange(of: dataManager.rides) { oldValue, newValue in
            goalManager.updateProgress()
        }
    }
}

#Preview {
    GoalView(dataManager: PreviewDataManager())
}
