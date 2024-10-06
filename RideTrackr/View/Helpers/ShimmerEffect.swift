//
//  ShimmerEffect.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 7/7/2024.
//
import SwiftUI

extension View {
    @ViewBuilder
    func shimmer(_ config: ShimmerConfig, isLoading: Bool) -> some View {
        self.modifier(ShimmerEffectHelper(config: config, isLoading: isLoading))
    }
}

struct ShimmerConfig {
    var tint: Color
    var highlight: Color
    var blur: CGFloat = 0
    var highlightOpacity: CGFloat = 1
    var speed: CGFloat = 0.75
    var blendMode: BlendMode = .softLight
    
    static let defaultConfig = ShimmerConfig(tint: .black.opacity(0.5), highlight: .gray.opacity(0.5), blur: 10)
}

struct ShimmerEffectHelper: ViewModifier {
    var config: ShimmerConfig
    var isLoading: Bool
    @State private var moveTo: CGFloat = -0.7
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    shimmerOverlay(content: content)
                }
            }
    }
    
    @ViewBuilder
    private func shimmerOverlay(content: Content) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.clear)
            .mask {
                content
            }
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    let extraOffset = (size.height / 2.5) + config.blur
                    Rectangle()
                        .fill(config.highlight)
                        .mask {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    .linearGradient(colors: [
                                        .white.opacity(0),
                                        config.highlight.opacity(config.highlightOpacity),
                                        .white.opacity(0)
                                    ], startPoint: .top, endPoint: .bottom)
                                )
                                .blur(radius: config.blur)
                                .rotationEffect(.init(degrees: -70))
                                .offset(x: moveTo > 0 ? extraOffset : -extraOffset)
                                .offset(x: size.width * moveTo)
                        }
                        .blendMode(config.blendMode)
                }
                .mask {
                    content
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    moveTo = 0.7
                }
            }
            .animation(.linear(duration: config.speed).repeatForever(autoreverses: false), value: moveTo)
    }
}
