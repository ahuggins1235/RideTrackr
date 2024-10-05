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

    @Namespace private var namespace

    private var greetingString: String {
        return GetGreetingString()
    }

    // MARK: - body
    var body: some View {
        NavigationStack {

            ScrollView {
                VStack(alignment: .leading) {

                    // MARK: - stat views
                    TrendPreviewView()
                        .redacted(if: healthManager.queryingHealthKit)
                        .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)
                        

                    // MARK: - recent ride preview
                    VStack(alignment: .leading) {

                        HStack(alignment: .bottom) {
                            Text("Your Last Ride")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.accent)

                            Spacer()

                            Text("Show more...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.accent)
                        }

                        if dataManager.rides.count > 0 {

                            NavigationLink(value: dataManager.rides.first!) {
                                LargeRidePreview(ride: $dataManager.rides.first!, queryingHealthKit: $healthManager.queryingHealthKit)
                                        .redacted(if: healthManager.queryingHealthKit)
                                        .shimmer(ShimmerConfig.defaultConfig, isLoading: healthManager.queryingHealthKit)
                                    
                                }.foregroundStyle(Color.primary)

                        }
                    } 
                        .padding(.top)

                    // MARK: - recent ride cards
                    RecentRidesCardList()
                        .frame(height: 300)
                        .redacted(if: healthManager.queryingHealthKit)
                        .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)

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
            HKManager.shared.queryingHealthKit = false
            DataManager.shared.rides = previewRideArray
        }
}

