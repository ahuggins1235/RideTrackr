//
//  MapOverlayPicker.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 2/10/2024.
//

import SwiftUI

struct MapOverlayPicker: View {

    @Binding var selectedOverlay: MapOverlayType
    @State var expanded: Bool = false
    @Binding var selectedZone: HeartRateZone?
    @Binding var keyHigh: Double?
    @Binding var keyLow: Double?
    @Binding var colHigh: Color?
    @Binding var colLow: Color?

    var body: some View {
        ZStack(alignment: .leading) {
            // Main button area
            HStack {
                if selectedOverlay != .None || expanded {
                    selectedOverlay.icon
                        .foregroundStyle(selectedOverlay.iconColor)
                } else {
                    selectedOverlay.icon
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.accent)
                }
                
                Label("Drop Down Arrow", systemImage: "chevron.down")
                    .rotationEffect(Angle(degrees: expanded ? -180 : 0))
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                
            }
            .sensoryFeedback(.impact, trigger: expanded)
            .frame(alignment: .leading)
            .padding(9)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
                }
            }
            // MARK: - Key

            if !expanded && selectedOverlay != .None {
                
                if selectedOverlay == .HeartRateZone {
                    
                    VStack(spacing: -5) {
                        ForEach(HeartRateZone.allCases) { zone in
                            Text(String(zone.rawValue))
                                .bold()
                                .foregroundStyle(selectedZone == zone ? zone.colour : (selectedZone == .none ? zone.colour : .secondary))
                                .padding()
                                .background(.ultraThickMaterial)
                                .clipShape(Circle())
                                .transition(.opacity)
                                .contentShape(Circle())
                                .onTapGesture {
                                    selectedZone = selectedZone == zone ? .none : zone
                                }
                                .offset(y: 140)
                                .sensoryFeedback(.impact, trigger: selectedZone)
                            
                        }
                    }
                    
                } else {
                    
                    if let keyHigh = keyHigh, let keyLow = keyLow {
                        HStack {
                            Text("\(Int(keyLow * getConversionValue()))")
                            
                            Capsule()
                                .fill(LinearGradient(colors: [colLow!, colHigh!], startPoint: .leading, endPoint: .trailing))
                            
                            Text("\(Int(keyHigh * getConversionValue()))")
                        }
                        .frame(width: 120, height: 10)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(Capsule())
                        .offset(y: 48)
                        .transition(.opacity)
                    }
                }
            }
            
            //MARK: - Dropdown content
            if expanded {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(MapOverlayType.allCases) { overlay in
                        if overlay != selectedOverlay {
                            Button(action: {
                                withAnimation {
                                    
                                    selectedOverlay = overlay
                                    if overlay != .HeartRateZone {
                                        selectedZone = nil
                                    }
                                    expanded.toggle()
                                }
                            }) {
                                overlay.icon
                                    .foregroundStyle(overlay.iconColor)
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                    }
                }
                .padding(9)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: 100) // Adjust this value based on your header height
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity.combined(with: .move(edge: .bottom))
                ))
            }
        }
        .bold()
    }
    
    func getConversionValue() -> Double {
        
        let conversionValue: Double
        
        switch selectedOverlay {
            case .Speed:
                conversionValue = SettingsManager.shared.distanceUnit.distanceConversion
            case .Altitude:
                conversionValue = SettingsManager.shared.distanceUnit.smallDistanceConversion
            default:
                conversionValue = 1
        }
        return conversionValue
    }
}

#Preview {
    // Use @State to simulate the binding
    StateWrapper()
}

struct StateWrapper: View {
    @State private var selectedSampleType: MapOverlayType = .None
    @State private var selectedZone: HeartRateZone?
    var body: some View {
        MapOverlayPicker(
            selectedOverlay: $selectedSampleType,
            selectedZone: $selectedZone,
            keyHigh: .constant(25),
            keyLow: .constant(15),
            colHigh: .constant(.red),
            colLow: .constant(.blue)
        )
    }
}



/// Which kind of overaly the user selects
enum MapOverlayType: String, CaseIterable, Identifiable {
    case HeartRate = "Heart Rate"
    case HeartRateZone = "Heart Rate Zones"
    case Speed = "Speed"
    case Altitude = "Altitude"
    case None = "None"

    var id: MapOverlayType { self }

    var icon: AnyView {
        switch self {
        case .None:
            return AnyView(Label("Default", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill"))
        case .HeartRate:
            return AnyView(Label("Heart Rate", systemImage: "heart.fill").labelStyle(.titleAndIcon))
            case .HeartRateZone:
                return AnyView(Label("Heart Rate Zones", systemImage: "heart.text.square").labelStyle(.titleAndIcon))
        case .Speed:
            return AnyView(Label("Speed", systemImage: "speedometer").labelStyle(.titleAndIcon))
        case .Altitude:
            return AnyView(Label("Altitude", systemImage: "mountain.2.circle").labelStyle(.titleAndIcon))
        }
    }

    var iconColor: Color {
        switch self {
        case .HeartRate:
            return .heartRate
        case .HeartRateZone:
            return .green
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
            return Color(hex: "#2B45FA")
            case .HeartRateZone:
                return .orange
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
            case .HeartRateZone:
                return .orange
        case .Speed:
            return Color(hex: "#FACC2C")
        case .Altitude:
            return Color(hex: "#FA7200")
        case .None:
            return .accent
        }
    }
}
