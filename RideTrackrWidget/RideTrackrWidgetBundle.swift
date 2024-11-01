//
//  RideTrackrWidgetBundle.swift
//  RideTrackrWidget
//
//  Created by Andrew Huggins on 12/10/2024.
//

import WidgetKit
import SwiftUI

@main
struct RideTrackrWidgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        RideTrackrWidget()
        GoalTrackerWidget()
    }
}
