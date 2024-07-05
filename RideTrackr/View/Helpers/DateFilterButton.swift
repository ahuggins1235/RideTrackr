//
//  DateFilterPresetView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 3/7/2024.
//

import SwiftUI

struct DateFilterButton: View {

    var text: String
    var isSelected: Bool

    var body: some View {

        Text(text)
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(10)
            .bold()
            .font(.caption)
            .background {
                
            Capsule()
                    .fill(isSelected ? Color.accentColor : Color.cardBackground)
                .stroke(Color.accentColor, lineWidth: 2)
        }
    }
}

#Preview {

    @Previewable @State var preivewIsSelected: Bool = true
    @Previewable @State var preivewNotSelected: Bool = false

    DateFilterButton(text: "Last Week", isSelected: false)
    DateFilterButton(text: "Last Month",isSelected: true)
}
