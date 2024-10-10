//
//  CollapseView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 10/10/2024.
//

import SwiftUI

struct CollapseView<Content>: View where Content: View {
    
    @State private var content: () -> Content
    @State private var expanded: Bool = false
    private var Title: String
    
    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.Title = title
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(Title)
                    .font(.title3)
                Spacer()
                Label("Drop Down Arrow", systemImage: "chevron.right")
                    .rotationEffect(Angle(degrees: expanded ? 90 : 0))
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
            }
            .id(0)
            .padding()
            .bold()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
//                    value.scrollTo(0, anchor: .top)
                }
            }
            
            Divider()
                .padding([.horizontal, .bottom])
            
            if expanded {
                content()
            }
        }
    }
}

//#Preview {
//    @Previewable @State var input: some View = Text("Hello, World!")
//    
//    CollapseView("Hello") {
//        input
//    }
//}
