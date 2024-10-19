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
    @State var humidity: Double?
    @State var expanded: Bool = false

    var body: some View {

        if !temperature.isEmpty {

            Grid() {
                
                GridRow {
                    
                    if expanded {
                        
                        if let humidity = humidity {
                            if humidity != 0 {
                                
                                Label("\(Int(humidity))%", systemImage: "humidity.fill").labelStyle(.iconOnly)
                                Text("\(Int(humidity))%")
                            }
                        }
                    }
                }

                GridRow {
                    if expanded {
                        Label("", systemImage: "thermometer.medium").labelStyle(.iconOnly)
                    }
                    Text(temperature)
                }
                    

            }
            .contentShape(Rectangle())
            .foregroundStyle(.gray)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundStyle(.ultraThickMaterial))
            .onTapGesture {
                withAnimation(.bouncy) {
                    expanded.toggle()
                }
            }
            .sensoryFeedback(.impact, trigger: expanded)
        }
    }
}

#Preview {
    TemperatureView(temperature: "23°C", humidity: 64)
}
