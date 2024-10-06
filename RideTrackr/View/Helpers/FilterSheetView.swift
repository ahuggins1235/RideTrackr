//
//  DateFilterSheetView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 3/7/2024.
//

import SwiftUI

struct FilterSheetView: View {

    @Binding var showFilterSheet: Bool
    @Binding var filterEnabled: Bool
    @Binding var dateFilter: DateInterval
    @Binding var sortOrder: SortOrder

    var body: some View {

        NavigationStack {

            LazyVStack {
                
                HStack {
                    
                    Text("Sort By:")
                    Spacer()
                    Picker("Sort By", selection: $sortOrder) {
                        
                        ForEach(SortOrder.allCases) { sort in
                            Text(sort.rawValue).tag(sort.rawValue)
                        }
                    }
                }
                .padding(.top)
                .padding(.leading)

                Toggle("Custom Date Range:", isOn: $filterEnabled)
                    .padding()

                if filterEnabled {
                    DateIntervalPickerView(startDate: $dateFilter.start, endDate: $dateFilter.end)
                        .transition(.opacity)
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
                        sortOrder = .date
                    }
                }
            }
                .animation(.interactiveSpring(duration: 0.5), value: filterEnabled)
        }
    }
}

#Preview {

    @Previewable @State var showFilterSheet: Bool = true
    @Previewable @State var filterEnabled: Bool = false
    @Previewable @State var dateFilter: DateInterval = DateInterval()
    @Previewable @State var sortOrder: SortOrder = .date

    FilterSheetView(showFilterSheet: $showFilterSheet, filterEnabled: $filterEnabled, dateFilter: $dateFilter, sortOrder: $sortOrder)
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

enum SortOrder: String, CaseIterable, Identifiable {
    
    case date = "Date"
    case distance = "Distance"
    case energy = "Energy"
    case duration = "Duration"
    
    var id: SortOrder { self }
}
