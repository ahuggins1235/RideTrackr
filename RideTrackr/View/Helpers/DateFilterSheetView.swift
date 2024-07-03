//
//  DateFilterSheetView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 3/7/2024.
//

import SwiftUI

struct DateFilterSheetView: View {

    @Binding var showFilterSheet: Bool
    @Binding var filterEnabled: Bool
    @Binding var dateFilter: DateInterval
    @State private var selectedFilter: DateFilter?

    var body: some View {

        NavigationStack {

            VStack {

                Toggle("Filter By Date", isOn: $filterEnabled)
                    .padding()


                if filterEnabled {
                    DateIntervalPickerView(startDate: $dateFilter.start, endDate: $dateFilter.end)
                        .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .bottom), removal: .move(edge: .bottom))))
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(DateFilter.allCases) { filter in
                                DateFilterPresetView(
                                    text: filter.rawValue,
                                    isSelected: filter == selectedFilter
                                )
                                    .padding(.vertical)
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
                        .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .bottom), removal: .move(edge: .bottom))))
                }

                Spacer()

            }.toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showFilterSheet.toggle() }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {

                        dateFilter.start = Date()
                        dateFilter.end = Date()

                        filterEnabled = false
                    }
                }
            }
                .animation(.interactiveSpring(duration: 0.2), value: filterEnabled)
        }
    }
}

#Preview {

    @Previewable @State var showFilterSheet: Bool = true
    @Previewable @State var filterEnabled: Bool = false
    @Previewable @State var dateFilter: DateInterval = DateInterval()

    DateFilterSheetView(showFilterSheet: $showFilterSheet, filterEnabled: $filterEnabled, dateFilter: $dateFilter)
}

enum DateFilter: String, CaseIterable, Identifiable {

    case week = "Last Week"
    case oneMonth = "Last Month"
    case threeMonths = "Three Months"
    case year = "Last Year"

    var id: DateFilter { self }

    var interval: DateInterval {

        switch self {
        case .week:
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            return DateInterval(start: startDate, end: Date())

        case .oneMonth:
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            return DateInterval(start: startDate, end: Date())

        case .threeMonths:
            let startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
            return DateInterval(start: startDate, end: Date())

        case .year:
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
            return DateInterval(start: startDate, end: Date())
        }
    }
}
