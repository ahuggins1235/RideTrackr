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
    @State var scrollProxy: ScrollViewProxy
    private var Title: String

    init(_ title: String, proxy: ScrollViewProxy, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.Title = title
        self.scrollProxy = proxy
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            scrollProxy.scrollTo(Title, anchor: .top)
                        }
                    }
                }
            }

            Divider()
                .padding([.horizontal, .bottom])

            if expanded {
                content()
                    .id(Title)
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
