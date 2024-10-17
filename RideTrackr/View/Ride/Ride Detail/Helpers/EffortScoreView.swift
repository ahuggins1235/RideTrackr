//
//  EffortScoreView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 5/7/2024.
//

import SwiftUI
import PolyKit

struct EffortScoreView: View {

    public let score: Double
    @State var animate = false
    @State var showTip = false

    var body: some View {
        ZStack {

            Text(String(Int(score)))
                .font(.largeTitle)
                .fontDesign(.rounded)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .background {

                Polygon(count: Int(score) + 3, relativeCornerRadius: 0.2)
                    .fill(.effort.gradient)
                    .stroke(Color.white, lineWidth: 5)
                    .rotationEffect(Angle(degrees: animate ? 0 : 30))
                    .shadow(color: .purple, radius: 30)
                    .brightness(animate ? 0 : 0.3)
            }
        }
        .onTapGesture {
            
            // First animation - reverse to initial state
            withAnimation(.interactiveSpring(duration: 0.75, extraBounce: 0.4)) {
                animate = false
            }
            
            // Second animation - return to completed state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interactiveSpring(duration: 0.75, extraBounce: 0.4)) {
                    animate = true
                }
            }
            
            withAnimation {
                showTip.toggle()
            }
        }
            .onAppear {

            withAnimation(.interactiveSpring(duration: 1.5, extraBounce: 0.4)) {
                animate = true
            }
        }
            .overlay {
                
            if showTip {
                VStack(alignment: .leading, spacing: 5) {
                    
                        Text("Effort Score: \(Int(score))")
                            .lineLimit(1)
                            .bold()
                            .font(.headline)
                    Divider()
                    
                    Text("Your effort score measures the intensity of your ride based on factors such as heart rate and duration.")
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                }
                .foregroundStyle(.primary)
                    .frame(width: 175, height: 150)
                    .padding(10)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .transition(.move(edge: .trailing).combined(with: .opacity).combined(with: .scale))
                    .offset(x: showTip ? -130 : 0, y: 50)
                    
            }
        }
            .onTapGesture {
                withAnimation{
                    showTip.toggle()
                }
            }
    }
}

#Preview {
    EffortScoreView(score: 10)
}
