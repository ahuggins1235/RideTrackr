//
//  HomeView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI
import SwiftData
import CoreData

@MainActor
struct HomeView: View {

    // MARK: - Properties
    @ObservedObject var healthManager: HKManager = HKManager.shared
    @ObservedObject var dataManager: DataManager = DataManager.shared
    @ObservedObject var navigationManager: NavigationManager = NavigationManager.shared
    @ObservedObject var trendManager: TrendManager = TrendManager.shared
    @ObservedObject var settingsManager: SettingsManager = SettingsManager.shared
    @State var previewRide = PreviewRide
    @Namespace private var namespace

    private var greetingString: String {
        return GetGreetingString()
    }

    // MARK: - body
    var body: some View {
        NavigationStack(path: $navigationManager.homeNavPath) {

            ScrollView {
                VStack(alignment: .leading) {

                    // MARK: - stat views
                    TrendPreviewView()
                        .redacted(if: healthManager.queryingHealthKit)
                        .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)


                    // MARK: - recent ride preview
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
//                                    .foregroundStyle(.secondary)
                                    
                                    LargeRidePreview(ride: $dataManager.rides.first!, queryingHealthKit: $healthManager.queryingHealthKit)
                                        .redacted(if: healthManager.queryingHealthKit)
                                        .shimmer(ShimmerConfig.defaultConfig, isLoading: healthManager.queryingHealthKit)
                                }
                            }.foregroundStyle(Color.primary)

                        } else {

                            LargeRidePreview(ride: $previewRide, queryingHealthKit: $healthManager.queryingHealthKit)
                                .redacted(reason: .placeholder)
                                .shimmer(.defaultConfig, isLoading: true)
                        }
                    }
                        .padding(.top)                                                                                                
                    if !healthManager.queryingHealthKit {
                        
                        
                        // MARK: - recent ride cards
                        RecentRidesCardList()
                            .frame(height: 300)
                            .redacted(if: healthManager.queryingHealthKit)
                            .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)
                    } else {
                        VStack {
                            HStack {
                                Text("Recent Rides")
                                    .font(.headline)
                                    .bold()
//                                    .foregroundStyle(.accent)
                                
                                Spacer()
                                
                                Text("Show more...")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
//                                    .foregroundStyle(.accent)
                                    
                                
                            }
//                            .foregroundStyle(.secondary)
                            .offset(y: 15)
                            .onTapGesture {
                                navigationManager.selectedTab = .RideList
                            }
                            
                            RideCardPreview(ride: PreviewRide).padding()
                                .redacted(reason: .placeholder)
                                .shimmer(.defaultConfig, isLoading: true)
                        }
                        
                    }
                }.padding(.horizontal)
                    .navigationTitle(greetingString)
            }
                .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }

                .refreshable {

                withAnimation {
                    dataManager.refreshRides()
                }
            }
                .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

// MARK: - Helper Functions
func GetGreetingString() -> String {

    let hour = Calendar.current.component(.hour, from: Date())

    switch hour {
    case 6..<12:
        return "Good morning"
    case 12..<18:
        return "Good afternoon"
    default:
        return "Good evening"
    }

}

// MARK: - Previews
#Preview("Home View") {
    HomeView(trendManager: PreviewTrendManager())
        .onAppear {
        HKManager.shared.queryingHealthKit = true
//        DataManager.shared.rides = previewRideArray
    }
}

