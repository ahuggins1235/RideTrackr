//
//  RideTrackrWidget.swift
//  RideTrackrWidget
//
//  Created by Andrew Huggins on 12/10/2024.
//

import WidgetKit
import SwiftUI




struct RideTrackrWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: RideEntry

    var body: some View {
        switch family {
            case .systemSmall:
                SmallRideWidget(entry: entry)
            default:
                Text("Not Implemented")
        }
    }
}

struct RideTrackrWidget: Widget {
    let kind: String = "RideTrackrWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                RideTrackrWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Rectangle().fill(Color.clear)
                    }
            } else {
                RideTrackrWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Latest Ride")
        .description("This displays the latest ride you've logged.")
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    RideTrackrWidget()
} timeline: {
    RideEntry(date: .now, ride: PreviewRide)
}
