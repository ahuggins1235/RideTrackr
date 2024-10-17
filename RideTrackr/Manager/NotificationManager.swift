//
//  NotificationManager.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 16/11/2023.
//

import Foundation
import UserNotifications

final class NotificationManager: ObservableObject, @unchecked Sendable {
    
    static let shared = NotificationManager()

    @Published var permissionGranted: Bool = false

    init() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.permissionGranted = true
            } else {
                self.requestPermissions()
            }
        }

    }

    private func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { success, error in
            if success {
                self.permissionGranted = true
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func sendNotification(ride: Ride) {
        if !permissionGranted {
            return
        }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New Workout Added"
        notificationContent.subtitle = "A new workout has been added to your HealthStore. Energy Burned: \(ride.activeEnergy)."
        
        let notificationLink = "ridetrackr://ride/\(ride.rideDate)"
        notificationContent.userInfo = ["deeplink": notificationLink]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let req = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)

        UNUserNotificationCenter.current().add(req)
    }
}
