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

                        if let recentRide = dataManager.rides.first {

                            NavigationLink(value: recentRide) {
                                LargeRidePreview(ride: recentRide, queryingHealthKit: $healthManager.queryingHealthKit)

//                                    .matchedTransitionSource(id: "preview", in: namespace)
                            }.foregroundStyle(Color.primary)

                        } else {
                            LargeRidePreview(ride: Ride(), queryingHealthKit: $healthManager.queryingHealthKit)
                        }
                    }
                        .padding(.top)

                    // MARK: - recent ride cards
                    RecentRidesCardList()
                        .frame(height: 300)

                }.padding(.horizontal)
                .navigationTitle(greetingString)
            }
            .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride)
            }
            
            .refreshable {
//                healthManager.queryingHealthKit = true
                withAnimation {
                    dataManager.refreshRides()
                }
                    
//                healthManager.queryingHealthKit = false
                
            }
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
    HomeView()
}

