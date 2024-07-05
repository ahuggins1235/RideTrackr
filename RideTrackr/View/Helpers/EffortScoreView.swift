//
//  EffortScoreView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 5/7/2024.
//

import SwiftUI
import PolyKit

struct EffortScoreView: View {

    public let score: Int
    @State var animate = false

    var body: some View {
        ZStack {

            Text(String(score))
                .font(.largeTitle)
                .fontDesign(.rounded)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .background {

                    Polygon(count: score + 3, relativeCornerRadius: 0.2)
                    .fill(.purple.gradient)
                    .stroke(Color.white, lineWidth: 5)
                    .rotationEffect(Angle(degrees: animate ? 0 : 30))
                    .shadow(color: .purple, radius: 30)
                    .brightness(animate ? 0 : 0.3)
            }
        }
        .onAppear {
            
            withAnimation(.interactiveSpring(duration: 1.5, extraBounce: 0.4)) {
                animate = true
            }
        }
    }
}

#Preview {
    EffortScoreView(score: 10)
}
