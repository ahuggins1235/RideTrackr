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
    @ObservedObject var healthManager: HKManager = .shared
    @ObservedObject var dataManager: DataManager = .shared
    @State private var dateFilter = DateInterval()
    @State private var showFilterSheet = false
    @State private var filterEnabled = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.25)
    @State private var selectedFilter: DateFilter?
    @State private var selectedSort: SortOrder = .date
    @Namespace var animation

    private var filteredRides: [Ride] {
        
        if healthManager.queryingHealthKit {
            return previewRideArray
        }
        
        var sortedRides: [Ride] = []
        
        switch selectedSort {
            case .date:
                sortedRides.append(contentsOf: dataManager.rides.sorted(by: { $0.rideDate.compare($1.rideDate) == .orderedDescending }))
            case .distance:
                sortedRides.append(contentsOf: dataManager.rides.sorted(by: { $0.distance > $1.distance  }) )
            case .duration:
                sortedRides.append(contentsOf: dataManager.rides.sorted(by: { $0.duration > $1.duration }) )
            case .energy:
                sortedRides.append(contentsOf: dataManager.rides.sorted(by: { $0.activeEnergy > $1.activeEnergy }) )
        }

        sortedRides = sortedRides.filter { ride in

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
        
        return sortedRides
    }


    // MARK: - Body
    var body: some View {

        NavigationStack(path: $navigationManager.rideListNavPath) {

            VStack(spacing: 0) {
                
                // MARK: - Date filters
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(DateFilter.allCases) { filter in
                            DateFilterButton(
                                text: filter.rawValue,
                                isSelected: filter == selectedFilter
                            )
                                .padding(.vertical)
                                .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    
                                    selectedFilter = (selectedFilter == filter) ? nil : filter
                                    dateFilter = selectedFilter?.interval ?? DateInterval()
                                    if selectedFilter == filter {
                                        filterEnabled = true
                                    } else {
                                        filterEnabled = false
                                    }
                                }
                            }
                        }
                    }
                        .padding(.horizontal)
                }.scrollIndicators(.never)
                    .background(.ultraThickMaterial)
                
                Divider()
                
                // MARK: - Main list
                ScrollView {
                    LazyVStack {
                        if filteredRides.isEmpty {
                            Text("No Rides Found")
                        }

                        ForEach(filteredRides) { ride in

                            NavigationLink(value: ride) {
                                RideRowView(ride: ride)
                            }
                            .id(ride.id)
                            .redacted(if: healthManager.queryingHealthKit)
                            .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)
                        }
                    }
                        .padding(.top)
                }

                    .background(Color(uiColor: .systemGroupedBackground))
                    .refreshable {
                    withAnimation(.default) {
                        dataManager.refreshRides()
                    }
                }
                    .navigationDestination(for: Ride.self) { ride in
                    RideDetailView(ride: ride)
                }
            }
            // MARK: - Filter sheet
            .sheet(isPresented: $showFilterSheet) {

                FilterSheetView(showFilterSheet: $showFilterSheet, filterEnabled: $filterEnabled, dateFilter: $dateFilter, sortOrder: $selectedSort)
                    .onChange(of: filterEnabled, { oldValue, newValue in
                        selectedDetent = filterEnabled ? .fraction(0.4) : .fraction(0.25)
                })
                    .presentationDetents([.fraction(0.4), .fraction(0.25)], selection: $selectedDetent)
                    .presentationDragIndicator(.hidden)
            }

                .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        showFilterSheet.toggle()
                    } label: {
                        Label("Sorting", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
                .toolbarBackground(.cardBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("Your Rides")
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK:  - Preview
#Preview {
    RideListView(dataManager: PreviewDataManager())
}
