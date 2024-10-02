//
//  MapOverlayPicker.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/10/2024.
//

import SwiftUI

struct MapOverlayPicker: View {
    
    @Binding var selectedOverlay: MapOverlayType
    
    var body: some View {
        Button  {
            withAnimation {
                cycleSelectedSampleType()
            }
        } label: {
            selectedOverlay.icon
                .foregroundStyle(selectedOverlay.iconColor)
        }
        .contentTransition(.symbolEffect(.replace))
        .padding(9)
        .background(.ultraThickMaterial)
        .clipShape(Capsule())
        .bold()
    }
    
    func cycleSelectedSampleType() {
        let allCases = MapOverlayType.allCases
        if let currentIndex = allCases.firstIndex(of: selectedOverlay) {
            let nextIndex = allCases.index(after: currentIndex)
            selectedOverlay = nextIndex == allCases.endIndex ? allCases.first! : allCases[nextIndex]
        }
    }
}

#Preview {
    // Use @State to simulate the binding
    StateWrapper()
}

struct StateWrapper: View {
    @State private var selectedSampleType: MapOverlayType = .None
    
    var body: some View {
        MapOverlayPicker(selectedOverlay: $selectedSampleType)
    }
}



/// Which kind of overaly the user selects
enum MapOverlayType: String, CaseIterable, Identifiable {
    case HeartRate = "Heart Rate"
    case Speed = "Speed"
    case Altitude = "Altitude"
    case None = "None"
    
    var id: MapOverlayType { self }
    
    var icon: AnyView {
        switch self {
            case .HeartRate:
                return AnyView(Label("Heart Rate", systemImage: "heart.fill").labelStyle(.titleAndIcon))
            case .Speed:
                return AnyView(Label("Speed", systemImage: "speedometer").labelStyle(.titleAndIcon))
            case .Altitude:
                return AnyView(Label("Altitude", systemImage: "mountain.2.fill").labelStyle(.titleAndIcon))
            case .None:
                return AnyView(Label("Default", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill").labelStyle(.iconOnly))
        }
    }
    
    var iconColor: Color {
        switch self {
            case .HeartRate:
                return .heartRate
            case .Speed:
                return .speed
            case .Altitude:
                return .altitude
            case .None:
                return .accent
        }
    }
    
    var minColor: Color {
        switch self {
            case .HeartRate:
                return Color(hex: "#2B45FA                    ")
            case .Speed:
                return Color(hex: "#2D40FA")
            case .Altitude:
                return Color(hex: "#29FA31")
            case .None:
                return .accent
        }
    }
    
    var maxColor: Color {
        switch self {
            case .HeartRate:
                return Color(hex: "#FF0010")
            case .Speed:
                return Color(hex: "#FACC2C")
            case .Altitude:
                return Color(hex: "#FA7200")
            case .None:
                return .accent
        }
    }
}
