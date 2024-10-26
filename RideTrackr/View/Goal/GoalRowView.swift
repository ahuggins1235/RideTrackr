//
//  GoalRowView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 24/10/2024.
//

import SwiftUI

struct GoalRowView: View {
    
    @State var ride: Ride
    @Binding var selectedGoal: GoalType?
    
    var dataString: String {
        if let selectedGoal = selectedGoal {
            
            var dataString: String = ""
            
            switch selectedGoal {
                case .Altitude: dataString = "\(ride.altitudeGained.round(to: 1))"
                case .Distance: dataString = "\(ride.distance.round(to: 2))"
                case .Duration: dataString = "\(Int(ride.duration / 60))"
                case .Energy: dataString = "\(Int(ride.activeEnergy))"
            }
            
            return "\(dataString) \(selectedGoal.unit)"
        }
        return ""
    }
    
    var body: some View {
        HStack {
            Text(ride.shortDateString)
                .bold()
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let selectedGoal = selectedGoal {
                
                Text(dataString)
                    .contentTransition(.numericText())
                    .foregroundStyle(selectedGoal.color)
                    .bold()
            } else {
                Text("--")
                    .bold()
                    .contentTransition(.numericText())
            }
        }
        .padding()
        .background(.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

#Preview {
    GoalRowView(ride: PreviewRide, selectedGoal: .constant(.Altitude))
}
