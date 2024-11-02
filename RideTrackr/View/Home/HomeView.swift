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
    @MainActor
    var body: some View {
        NavigationStack(path: $navigationManager.homeNavPath) {

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - stat views
                    TrendPreviewView()
                        .redacted(if: healthManager.queryingHealthKit)
                        .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)

                    // MARK: - recent ride preview
                    RecentRidePreview()
                        .redacted(if: healthManager.queryingHealthKit)
                        .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)

                    GoalPreviewView()
                        .redacted(if: healthManager.queryingHealthKit)
                        .shimmer(.defaultConfig, isLoading: healthManager.queryingHealthKit)

                    RecentRidesHomeView()
                    
                    Spacer()

                }
                .padding(.horizontal)
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
    HomeView(healthManager: PreviewHKManager(), dataManager: PreviewDataManager(), trendManager: PreviewTrendManager())
        .onAppear {
        HKManager.shared.queryingHealthKit = true
//        DataManager.shared.rides = previewRideArray
    }
}

