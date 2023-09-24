//
//  HomeView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/7/2023.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var healthManager: HealthManager
    @Namespace var namespace
    @State var show = false

    private var greetingString: String {
        return GetGreetingString()
    }

    var body: some View {

//        ZStack {

        ScrollView {
            VStack(alignment: .leading) {

                Text(greetingString)
                    .font(.largeTitle)
                    .bold()

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {

                    HomeStatCardView(bgColor: .red, title: "Average Heart Rate", icon: "heart.fill", data: "162 BMP")
                    HomeStatCardView(bgColor: .blue, title: "Average Speed", icon: "speedometer", data: "14 KM/H")
                    HomeStatCardView(bgColor: .green, title: "Average Distance", icon: "figure.outdoor.cycle", data: "11.4 KM")
                    HomeStatCardView(bgColor: .orange, title: "Average Active Energy", icon: "flame.fill", data: "1,042 KJ")

                }

                Text("Most Recent Ride")
                    .font(.title)
                    .bold()

                Spacer()
                
                LargeRidePreview(ride: $healthManager.recentRide)
                    .onTapGesture {
                        show.toggle()
                    }
                
//                if !show {
//                    ZStack {
//
//                        LargeRidePreview(ride: $healthManager.recentRide)
//                            .matchedGeometryEffect(id: "ridePreview", in: namespace)
//
//                    }.onTapGesture {
//                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                            show.toggle()
//                        }
//                    }
//                        .zIndex(2)
//
//                }
            }.padding(.horizontal)
        }
        .sheet(isPresented: $show) {
            RideDetailView(ride: healthManager.recentRide)
                .navigationTitle(healthManager.recentRide.dateString)
        }

//            if show {
//                RideDetailView(ride: healthManager.recentRide, namespace: namespace, show: $show, recentRide: true).background(.ultraThickMaterial)
//            }

//        }
    }
}

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

#Preview("Home View") {
    HomeView().environmentObject(HealthManager())
}
