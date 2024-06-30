//
//  RideListView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import SwiftUI
import SwiftData
import CoreData

@MainActor
struct RideListView: View {

    // MARK: - Properties
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var healthManager: HKManager = HKManager.shared
    @ObservedObject var dataManager: DataManager = DataManager.shared
    @State var dateFilter = Date()
    @Environment(\.modelContext) private var context
//    @Query(sort: \Ride.rideDate, order: .reverse) var rides: [Ride]


    // MARK: - Body
    var body: some View {

        NavigationStack(path: $navigationManager.rideListNavPath) {

            VStack {
                List {

                    ForEach(dataManager.rides) { ride in

                        NavigationLink(value: ride) {
                            RideRowView(ride: ride)
                        }
                    }
                }
                    .navigationDestination(for: Ride.self) { ride in
                    RideDetailView(ride: ride)
                }
                Button {
                    dataManager.insertRide(healthManager.rides.first!)
                } label: {
                    Text("Add Ride to DB")
                }

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
