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
        StaticConfiguration(kind: kind, provider: RideProvider()) { entry in
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

struct GoalTrackerWidget: Widget {
    let kind: String = "GoalTrackerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GoalProvider()) { entry in
            if #available (iOS 17.0, *) {
                GoalTrackerWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Rectangle()
                            .fill(Color.clear)
                    }
            } else {
                GoalTrackerWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Your Goals")
        .description("This displays your progress towards your goals.")
        .contentMarginsDisabled()
    }
}


struct GoalTrackerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: GoalEntry
    
    var body: some View {
        SmallGoalView(entry: entry)
    }
}

#Preview(as: .systemSmall) {
    GoalTrackerWidget()
} timeline: {
    GoalEntry(date: Date(), distanceGoal: .defaultDistance, energyGoal: .defaultEnergy, durationGoal: .defaultDuration, altitudeGoal: .defaultAltiudeGained)
}
