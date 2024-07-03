//
//  RideListView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 29/7/2023.
//

import SwiftUI
import SwiftData
import CoreData
import UIKit

@MainActor
struct RideListView: View {

    // MARK: - Properties
    @ObservedObject var navigationManager: NavigationManager = .shared
//    @ObservedObject var healthManager: HKManager = .shared
    @ObservedObject var dataManager: DataManager = .shared
    @State private var dateFilter = DateInterval()
    @State private var showFilterSheet = false
    @State private var filterEnabled = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var selectedFilter: DateFilter?

    private var filteredRides: [Ride] {

        dataManager.rides.filter { ride in

            if !filterEnabled { return true }

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
    }


    // MARK: - Body
    var body: some View {

        NavigationStack(path: $navigationManager.rideListNavPath) {

            VStack {
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(DateFilter.allCases) { filter in
                            DateFilterPresetView(
                                text: filter.rawValue,
                                isSelected: filter == selectedFilter
                            )
//                            .padding(.vertical)
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    selectedFilter = (selectedFilter == filter) ? nil : filter
                                    dateFilter = selectedFilter?.interval ?? DateInterval()
                                }
                            }
                        }
                    }
                    .padding()
                }.scrollIndicators(.hidden)

                ZStack {

                    ScrollView {

                        if filteredRides.count == 0 {
                            Text("No Rides Found")
                        }

                        ForEach(filteredRides) { ride in

                            NavigationLink(value: ride) {
                                RideRowView(ride: ride)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
//                                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                            .blur(radius: phase.isIdentity ? 0 : 10)
                                    }
                            }
                        }
                    }
                        .refreshable {
                        withAnimation(.default) {
                            dataManager.refreshRides()
                        }
                    }
                        .navigationDestination(for: Ride.self) { ride in
                        RideDetailView(ride: ride)
                    }
                    
//                    VStack {
//                        Rectangle()
//                            .fill(.white)
//                            .frame(height: 15)
//                            .blur(radius: 10)
//                        Spacer()
//                            
//                    }
//                    .edgesIgnoringSafeArea(.top) // Optional, if you want the blur to extend to the top edge
                    
//                    if healthManager.queryingHealthKit {
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(.background)
//                            .padding([.horizontal, .bottom])
//
//                        ProgressView("Loading")
//                            .ignoresSafeArea()
//                    }
                }
            }
            // MARK: - Filter sheet
            .sheet(isPresented: $showFilterSheet) {

                DateFilterSheetView(showFilterSheet: $showFilterSheet, filterEnabled: $filterEnabled, dateFilter: $dateFilter)
                    .onChange(of: filterEnabled, { oldValue, newValue in
                    selectedDetent = filterEnabled ? .medium : .fraction(0.15)
                })
                    .presentationDetents([.medium, .fraction(0.15)], selection: $selectedDetent)
                    .presentationDragIndicator(.hidden)
            }

                .toolbar {

                Button {
                    showFilterSheet.toggle()
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
    RideListView(dataManager: PreviewDataManager())
}
