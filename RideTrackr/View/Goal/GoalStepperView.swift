//
//  GoalStepperView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 26/10/2024.
//

import SwiftUI

struct GoalStepperView: View {
    
    @Binding var value: Double
    let increment: Double
    let color: Color
    @Binding var isEnabled: Bool
    let title: String
    
    var body: some View {
        
        HStack {
            Group {
                Text(title)
                    .frame(width: 75, alignment: .leading)
                
                Spacer()
                
                Button {
                    value -= increment
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(StepperButtonStyle(color: color))
                
                TextField("Goal", value: $value, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 75)
                    .keyboardType(.numberPad)
                
                Button {
                    value += increment
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(StepperButtonStyle(color: color))
            }
            .disabled(!isEnabled)
            .foregroundStyle(isEnabled ? .primary : .secondary)
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(.switch)
            
        }
        .bold()
        
    }
}

#Preview {
    
    @Previewable @State var value: Double = 0
    @Previewable @State var isEnabled: Bool = true
    
    GoalStepperView(value: $value, increment: 10, color: .orange, isEnabled: $isEnabled, title: "Energy")
}

struct StepperButtonStyle: ButtonStyle {
    
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(height: 35)
            .background(color)
            .clipShape(Circle())
            .contentShape(Circle())
            .brightness(configuration.isPressed ? 0.1 : 0)
    }
}
