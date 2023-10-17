//
//  HomeStatCardView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct HomeStatCardView: View {
    
    @State var bgColor: Color
    @State var title: String
    @State var icon: String
    @State var data: String
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(bgColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 4, x: 2, y: 2)
                
            
            VStack(spacing: 20) {
                HStack {
                    Text(title)
                    Spacer()
                    Image(systemName: icon)
                }.font(.headline)
                
                Text(data)
                    .font(.title2)
                    .bold()
                
            }.foregroundStyle(.white)
                .padding()
        }
        
    }
}

#Preview {
    HomeStatCardView(bgColor: .red, title: "Average Heart Rate", icon: "heart.fill", data: "162 BMP")
}
