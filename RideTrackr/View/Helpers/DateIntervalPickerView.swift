//
//  DateIntervalPickerView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/7/2024.
//

import SwiftUI

struct DateIntervalPickerView: View {
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var isPickingStart = true
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Select Date Range")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            
            DatePicker("Start Date:", selection: $startDate, in: ...Date(), displayedComponents: .date)
                .padding(.horizontal)
                
            DatePicker("End Date:", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                .padding(.horizontal)
        }
    }
}

#Preview {
    
    @Previewable @State var dateInterval: DateInterval = DateInterval(start: Date(), end: Date())
    
    DateIntervalPickerView(startDate: $dateInterval.start, endDate: $dateInterval.end)
}
