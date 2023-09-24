//
//  RideListView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import SwiftUI

struct RideListView: View {

    // MARK: - Properties
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var healthManager: HealthManager
    @State var dateFilter = Date()

    // MARK: - Body
    var body: some View {

        NavigationStack(path: $navigationManager.rideListNavPath) {

            List {
                if healthManager.rides.count > 0 {
                    Section("This Week") {

                        ForEach(healthManager.thisWeekRides) { ride in
                            NavigationLink(value: ride) {
                                RideRowView(ride: ride)
                            }
                        }
                    }

                    Section("This Month") {
                        ForEach (healthManager.thisMonthRide) { ride in

                            NavigationLink(value: ride) {
                                RideRowView(ride: ride)
                            }
                        }
                    }

                    Section("Older") {

                        ForEach (healthManager.rides.filter { ride in
                            let calendar = Calendar.current
                            let today = Date()
                            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!

                            return ride.rideDate < startOfMonth

                        }) { ride in
                            NavigationLink(value: ride) {
                                RideRowView(ride: ride)
                            }
                        }

                    }
                } else {
                    Text("No rides found ☹️")
                }
            }
                .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)

            }
                .toolbar {

                ToolbarItemGroup {

                    DatePicker("Choose Date", selection: $dateFilter)
                        .datePickerStyle(.compact)


                } label: {
                    Label("Date picker", systemImage: "calendar")

                }

            }
                .navigationTitle("Your Rides")
                .toolbar {
            }

        }


    }
}

// MARK:  - Preview
#Preview {
    RideListView()
        .environmentObject(NavigationManager())
        .environmentObject(HealthManager())
}
