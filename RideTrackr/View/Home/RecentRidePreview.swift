//
//  RecentRidePreview.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/11/2024.
//

import SwiftUI

struct RecentRidePreview: View {
    
    @ObservedObject var dataManager: DataManager = .shared
    @ObservedObject var healthManager: HKManager = .shared
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if dataManager.rides.count > 0 {
                
                NavigationLink(value: dataManager.rides.first!) {
                    VStack {
                        HStack(alignment: .bottom) {
                            Text("Your Last Ride")
                                .font(.headline)
                                .bold()
                            
                            Spacer()
                            
                            Text("Show more...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .unredacted()
                        .foregroundStyle(.accent)
                        
                        LargeRidePreview(ride: $dataManager.rides.first!, queryingHealthKit: $healthManager.queryingHealthKit)
                            .redacted(if: healthManager.queryingHealthKit)
                            .shimmer(ShimmerConfig.defaultConfig, isLoading: healthManager.queryingHealthKit)
                    }
                }.foregroundStyle(Color.primary)
                
            } else {
                VStack {
                    HStack(alignment: .bottom) {
                        Text("Your Last Ride")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        
                        Text("Show more...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .unredacted()
                    .foregroundStyle(.accent)
                    
                    LargeRidePreview(ride: .constant(PreviewRide), queryingHealthKit: .constant(true))
                        .redacted(reason: .placeholder)
                        .shimmer(.defaultConfig, isLoading: true)
                        .overlay {
                            if !healthManager.queryingHealthKit {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(.foreground)
                                        .opacity(0.2)
                                        .blur(radius: 10)
                                    
                                    Text("No rides found")
                                        .unredacted()
                                        .bold()
                                        .font(.title)
                                        .fontDesign(.rounded)
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    RecentRidePreview()
}
