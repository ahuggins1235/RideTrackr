//
//  DateFilterPresetView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 3/7/2024.
//

import SwiftUI

struct DateFilterPresetView: View {

    var text: String
    var isSelected: Bool

    var body: some View {

        Text(text)
            .foregroundStyle(isSelected ? .white : .primary)
            .padding()
            .bold()
            .font(.callout)
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

    DateFilterPresetView(text: "Last Week", isSelected: false)
    DateFilterPresetView(text: "Last Month",isSelected: true)
}
