//
//  HomeStatCardView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct TrendCardView: View {

    @State var bgColor: Color
    @State var title: String
    @State var icon: String
    @Binding var data: String
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(bgColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: bgColor, radius: 4)
//                .shadow(color: bgColor, radius: 4, x: 2, y: 2)
//                .shadow(radius: 4, x: 2, y: 2)
                
            
            VStack(spacing: 20) {
                HStack {
                    Text(title).unredacted()
                    Spacer()
                    Image(systemName: icon).unredacted()
                }.font(.headline)
                
                if !data.contains("nan") {
                    Text(data)
                        .font(.title2)
                        .bold()
                } else {
                    Text(String.placeholder(length: 6))
                        .redacted(reason: .placeholder)
                }
                
            }
            .contentTransition(.numericText())
            .foregroundStyle(.white)
                .padding()
        }
    }
}

#Preview {
    TrendCardView(bgColor: .red, title: "Average Heart Rate", icon: "heart.fill", data: Binding(get: { "162 BMP" } ))
}
