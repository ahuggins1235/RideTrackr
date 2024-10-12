//
//  StatDifferenceArrow.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 12/10/2024.
//
import SwiftUI

struct StatDifferenceArrow: View {

    @State var color: Color
    @Binding var data: Double


    var body: some View {

        ZStack {

            switch data {

            case let x where x > 10:

                ZStack {
                    Image(systemName: "arrowtriangle.up.fill").offset(x: 0, y: -4.5)
                    Image(systemName: "arrowtriangle.up.fill").offset(x: 0, y: 4.5)
                }

            case 1...10:

                Image(systemName: "arrowtriangle.up.fill")

            case -10..<0:

                Image(systemName: "arrowtriangle.down.fill")

            default:

                ZStack {
                    Image(systemName: "arrowtriangle.down.fill").offset(x: 0, y: -4.5)
                    Image(systemName: "arrowtriangle.down.fill").offset(x: 0, y: 4.5)
                }

            }
        }.foregroundStyle(color)

    }
}
