//
//  AppDelegate.swift
//  MuangUdonThaniMuseum
//
//  Created by Supannee Mutitanon on 4/9/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import KontaktSDK
import NotificationCenter
import UserNotifications
import Alamofire
import ObjectMapper
import GoogleMaps
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var beaconManager: KTKBeaconManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Kontakt.setAPIKey("dYysPEwOZXFSqTbtoioQDxWAffdJfAAB")
        GMSServices.provideAPIKey("AIzaSyDSKokO88Mtl_WJqJFtRjCjbgCxecDN290")
        
        beaconManager = KTKBeaconManager(delegate: self)

        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("app in background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("app in foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        beaconManager.stopMonitoringForAllRegions()
        beaconManager.stopRangingBeaconsInAllRegions()
        NotificationCenter.default.removeObserver(self)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // called when user interacts with notification (app not running in foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo
        let uuid = userInfo["uuid"]
        let vc = NotiDetailViewController()
        let uuidString = uuid as! String
        vc.uuid = uuidString.lowercased()
        let noti = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = noti
        self.window?.makeKeyAndVisible()
        
        return completionHandler()
    }
    
    // called if app is running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        print("userNotificationCenter")
        // show alert while app is running in foreground
        return completionHandler([UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.alert])
    }
}

extension AppDelegate: KTKBeaconManagerDelegate {
    
}
