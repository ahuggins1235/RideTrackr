//
//  TemperatureView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 8/11/2023.
//

import SwiftUI

struct TemperatureView: View {

    @State var temperature: String

    var body: some View {

        if !temperature.isEmpty {
            
//            ZStack {

//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .foregroundStyle(.ultraThickMaterial)

                Text(temperature)
                    .foregroundStyle(.gray)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(.ultraThickMaterial))

//            }
        }
    }
}

#Preview {
    TemperatureView(temperature: "23°C")
}
