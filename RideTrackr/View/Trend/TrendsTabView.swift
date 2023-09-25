//
//  TrendView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 25/9/2023.
//

import SwiftUI

struct TrendsTabView: View {

    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {

        NavigationStack {
            VStack {

                TabView(selection: $navigationManager.selectedTrendsTab) {

                    ForEach(TrendsTab.allCases) { trendTab in
                        trendTab.destination.tabItem { trendTab.label }.tag(trendTab.rawValue)
                    }

                }
                    .padding()
                    .backgroundStyle(.ultraThinMaterial)
                    .tabViewStyle(.page(indexDisplayMode: .never))

                ZStack {

                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 50)

                    HStack(spacing: 30) {
                        ForEach(TrendsTab.allCases) { trendTab in
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
                .navigationTitle("Trends")
        }

    }
}

#Preview {
    TrendsTabView().environmentObject(NavigationManager())
}
