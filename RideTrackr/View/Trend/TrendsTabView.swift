//
//  TrendView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import SwiftUI

@MainActor
struct TrendsTabView: View {

    @ObservedObject var navigationManager: NavigationManager = .shared

    var body: some View {


        VStack {

            TabView(selection: $navigationManager.selectedTrendsTab) {

                ForEach(TrendType.allCases) { trendTab in
                    trendTab.destination.tabItem { trendTab.label }.tag(trendTab.rawValue)
                }

            }
                .padding()

                .tabViewStyle(.page(indexDisplayMode: .never))

            ZStack {

                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 50)

                HStack(spacing: 30) {
                    ForEach(TrendType.allCases) { trendTab in
                        trendTab.label
                            .foregroundStyle(navigationManager.selectedTrendsTab == trendTab ? trendTab.selectionColour : Color.primary)
                            .onTapGesture {
                            navigationManager.selectedTrendsTab = trendTab
                        }
                    }
                }
            }
                .padding(.bottom)
        }
    }
}

#Preview {
    TrendsTabView()
}
