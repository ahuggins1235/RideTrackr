//
//  RecentRidesHomeView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/11/2024.
//
import SwiftUI

struct RecentRidesHomeView: View {
    
    @ObservedObject var healthManager: HKManager = .shared
    @ObservedObject var navigationManager: NavigationManager = .shared
    
    var body: some View {
        
        if !healthManager.queryingHealthKit {
            
            
            // MARK: - recent ride cards
            RecentRidesCardList()
//                .frame(idealHeight: 100)
                .redacted(if: healthManager.queryingHealthKit)
                .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)
        } else {
            VStack {
                HStack {
                    Text("Recent Rides")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.accent)
                    
                    Spacer()
                    
                    Text("Show more...")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.accent)
                    
                    
                }
                //                            .foregroundStyle(.secondary)
//                .offset(y: 15)
                .onTapGesture {
                    navigationManager.selectedTab = .RideList
                }
                
                RideCardPreview(ride: PreviewRide).padding()
                    .redacted(reason: .placeholder)
                    .shimmer(.defaultConfig, isLoading: true)
            }
        }
    }
}

