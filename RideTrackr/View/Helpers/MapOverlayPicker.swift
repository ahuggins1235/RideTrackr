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

    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
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

            if expanded {
                
                ForEach(MapOverlayType.allCases) { overlay in
                    
                    if overlay != selectedOverlay {
                        
                        Button(action: {
                            withAnimation {
                                selectedOverlay = overlay
                                expanded.toggle()
                            }
                        }) {
                            overlay.icon
                                .foregroundStyle(overlay.iconColor)
                                .labelStyle(.titleAndIcon)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
            .contentTransition(.symbolEffect(.replace))
            .padding(9)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
            return AnyView(Label("Altitude", systemImage: "mountain.2.circle").labelStyle(.titleAndIcon))
        case .None:
            return AnyView(Label("Default", systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill"))
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


//var body: some  View {
//    VStack {
//        
//        VStack(spacing: 0) {
//            // selected item
//            Button(action: {
//                withAnimation {
//                    showDropdown.toggle()
//                }
//            }, label: {
//                HStack(spacing: nil) {
//                    Text(options[selectedOptionIndex])
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                        .rotationEffect(.degrees((showDropdown ?  -180 : 0)))
//                }
//            })
//            .padding(.horizontal, 20)
//            .frame(width: menuWdith, height: buttonHeight, alignment: .leading)
//            
//            
//            // selection menu
//            if (showDropdown) {
//                let scrollViewHeight: CGFloat  = options.count > maxItemDisplayed ? (buttonHeight*CGFloat(maxItemDisplayed)) : (buttonHeight*CGFloat(options.count))
//                ScrollView {
//                    LazyVStack(spacing: 0) {
//                        ForEach(0..<options.count, id: \.self) { index in
//                            Button(action: {
//                                withAnimation {
//                                    selectedOptionIndex = index
//                                    showDropdown.toggle()
//                                }
//                                
//                            }, label: {
//                                HStack {
//                                    Text(options[index])
//                                    Spacer()
//                                    if (index == selectedOptionIndex) {
//                                        Image(systemName: "checkmark.circle.fill")
//                                        
//                                    }
//                                }
//                                
//                            })
//                            .padding(.horizontal, 20)
//                            .frame(width: menuWdith, height: buttonHeight, alignment: .leading)
//                            
//                        }
//                    }
//                    .scrollTargetLayout()
//                }
//                .scrollPosition(id: $scrollPosition)
//                .scrollDisabled(options.count <=  3)
//                .frame(height: scrollViewHeight)
//                .onAppear {
//                    scrollPosition = selectedOptionIndex
//                }
//                
//            }
//            
//        }
//        .foregroundStyle(Color.white)
//        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
//        
//    }
//    .frame(width: menuWdith, height: buttonHeight, alignment: .top)
//    .zIndex(100)
//    
//}
