//
//  AppDelegate.swift
//  RideTrackr
//
//  Created by Andrew Huggins on 16/10/2024.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let urlString = userInfo["deeplink"] as? String,
           let url = URL(string: urlString) {
            NotificationCenter.default.post(name: .init("HandleDeeplink"), object: url)
        }
        
        completionHandler()
    }
}
