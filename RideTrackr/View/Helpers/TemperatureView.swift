//
//  TemperatureView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 8/11/2023.
//

import SwiftUI

@MainActor
struct TemperatureView: View {

    @State var temperature: String

    var body: some View {

        if !temperature.isEmpty {
            
                Text(temperature)
                    .foregroundStyle(.gray)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 30, style: .continuous).foregroundStyle(.ultraThickMaterial))

        }
    }
}

#Preview {
    TemperatureView(temperature: "23°C")
}
