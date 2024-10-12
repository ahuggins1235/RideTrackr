//
//  Provider.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 12/10/2024.
//
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> RideEntry {
        RideEntry(date: Date(), ride: PreviewRide)
    }

    func getSnapshot(in context: Context, completion: @escaping (RideEntry) -> ()) {
        Task {
            completion(await getLatestRide())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        Task {
            let timeline = Timeline(entries: [await getLatestRide()], policy: .after(.now.advanced(by: 60 * 60 * 30)))
            completion(timeline)
        }
    }

    func getLatestRide() async -> RideEntry {

        let entry: RideEntry

        if let latestRide = await HKManager.shared.getRides(numRides: 1).first {
            entry = RideEntry(date: .now, ride: latestRide)
        } else {
            entry = RideEntry(date: .now, ride: PreviewRide)
        }
        return entry


    }
//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
