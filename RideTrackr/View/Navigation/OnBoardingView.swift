//
//  OnBoardingView.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 20/10/2024.
//
import SwiftUI

struct OnBoardingView: View {

    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    private var screens: [AnyView] {
        [
            AnyView(FirstOnboardingView(index: $currentScreen)),
            AnyView(SecondOnboardingView(index: $currentScreen))
        ]
    }

    @State private var currentScreen: Int = 0


    var body: some View {

        screens[currentScreen]
            .transition(.push(from: .trailing))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
}

#Preview("First View") {
    OnBoardingView()
}

struct FirstOnboardingView: View {

    @Binding var index: Int

    var body: some View {

        ZStack {

            Rectangle()
                .fill(.red.gradient)
                .ignoresSafeArea()
            VStack {

                VStack(spacing: 50) {

                    Image("AppIconBike")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)

                    Text("Welcome to RideTrackr")
                        .foregroundStyle(.white)
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)

                }
                    .padding()


                Spacer()

                VStack(spacing: 20) {

                    Text("Get the most out of your rides ")
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .font(.title2)


                    Button {
                        withAnimation {
                            index += 1
                        }
                    } label: {
                        Label("Get Started", systemImage: "chevron.right").labelStyle(RightIconStyle())
                            .bold()
                            .foregroundStyle(.black)
                            .padding()
                            .background(.white)
                            .clipShape(Capsule())
                    }
                }
                    .padding(.bottom, 50)
            }
                .padding(.top)
        }
    }
}

struct SecondOnboardingView: View {

    @Binding var index: Int
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    @ObservedObject var hkManager: HKManager = .shared
    var progress: Double? {
//        return 0.5
        if let fetchedRides = hkManager.fetchedRides {

            let percent = hkManager.resyncProgress / fetchedRides

            return percent
        }
        return nil
    }

    var body: some View {

        ZStack {

            Rectangle()
                .fill(.red.gradient)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {

                Text("Getting Your Rides")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 100)

                Spacer()

                VStack(spacing: 20) {
                    Text("Just fetching your rides from Apple Health. This may take a few minutes but we only need to do it once.")
                        .multilineTextAlignment(.center)
                        .fontWeight(.semibold)

                    if let count = hkManager.fetchedRides {
                        Text("Found \(Int(count)) rides...")
                    }
                    
//                    Text("Found 100 rides...")
                    
                    if let progress = progress {
                        ProgressView("\(Int(progress * 100))%", value: progress)
                            .progressViewStyle(.linear)
                            .padding()
                    }
                }
                    .padding()
            }
            .foregroundStyle(.white)
        }
            .onAppear {
            DataManager.shared.reyncData()
        }
            .onChange(of: hkManager.queryingHealthKit) { oldValue, newValue in
            print(newValue)
            if newValue == false {
                withAnimation {
                    firstLaunch = false
                }
            }
        }
    }
}

#Preview("Second View") {
    SecondOnboardingView(index: .constant(1), hkManager: PreviewHKManager.shared)

}
