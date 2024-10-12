//
//  LabelStyles.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 12/10/2024.
//
import SwiftUI

struct RightIconStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.title
            configuration.icon
        }
    }
}
