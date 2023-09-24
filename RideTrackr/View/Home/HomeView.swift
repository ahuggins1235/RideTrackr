//
//  HomeView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct HomeView: View {

    // MARK: - Properties
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var show = false
    @State private var selectedRide = Ride()

    private var greetingString: String {
        return GetGreetingString()
    }

    // MARK: - body
    var body: some View {
        NavigationStack {

            ScrollView {
                VStack(alignment: .leading) {

                    // MARK: - stat views
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {

                        HomeStatCardView(bgColor: .red, title: "Average Heart Rate", icon: "heart.fill", data: "162 BMP")
                        HomeStatCardView(bgColor: .blue, title: "Average Speed", icon: "speedometer", data: "14 KM/H")
                        HomeStatCardView(bgColor: .green, title: "Average Distance", icon: "figure.outdoor.cycle", data: "11.4 KM")
                        HomeStatCardView(bgColor: .orange, title: "Average Active Energy", icon: "flame.fill", data: "1,042 KJ")

                    }


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

                        if let recentRide = healthManager.recentRide {
                            NavigationLink(value: recentRide) {
                                LargeRidePreview(ride: Binding(get: { recentRide }, set: { _ in }), queryingHealthKit: $healthManager.queryingHealthKit)
                            }.foregroundStyle(Color.primary)

                        } else {
                            LargeRidePreview(ride: Binding(get: { PreviewRide }, set: { _ in }), queryingHealthKit: $healthManager.queryingHealthKit)
                        }
                    }
                        .padding(.top)
                    
                    
                    // MARK: - recent ride cards
                    
                    VStack(alignment: .leading) {
                        
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
                                .onTapGesture {
                                    navigationManager.selectedTab = .RideList
                                }
                            
                        }
                        
                        ZStack {
                            ScrollView(.horizontal) {
                                
                                HStack {
//                                    ForEach(previewRideArray.prefix(4).dropFirst()) { ride in
                                    ForEach(healthManager.rides.prefix(4).dropFirst()) { ride in
                                        NavigationLink(value: ride) {
                                            RideCardPreview(ride: ride)
                                                .padding(.vertical)
                                        }
                                        .foregroundStyle(Color.primary)
                                    }
                                }
                            }
                            
//                            HStack {
//                                // Apply blur effect at the top
//                                Spacer()
//                                
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .background(
//                                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.5)]), startPoint: .top, endPoint: .center)
//                                            .frame(height: 100)
//                                    )
//                                    .blur(radius: 10)
//                                
//                                Spacer()
//                                
//                                // Apply blur effect at the bottom
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .background(
//                                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .clear]), startPoint: .center, endPoint: .bottom)
//                                            .frame(height: 100)
//                                    )
//                                    .blur(radius: 10)
//                                
//                                Spacer()
//                            }

                            
                        }
                        
                    }
                    .padding(.vertical)
                    

                }.padding(.horizontal)
                
                // MARK: - toolbar
                    .toolbar {

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            healthManager.syncWithHK()
                        } label: {
                            Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                }
                    .navigationTitle(greetingString)
            }
            .navigationDestination(for: Ride.self) { ride in
                RideDetailView(ride: ride, show: $show)
            }
        }
//        // MARK: - ride detail view sheet
//            .sheet(isPresented: $show) {
//
////            if let recentRide = healthManager.recentRide {
//                RideDetailView(ride: PreviewRide, show: $show, recentRide: true)
//                    .navigationTitle(PreviewRide.dateString)
//
////            }
//        }
      


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
    HomeView().environmentObject(HealthManager())
}
