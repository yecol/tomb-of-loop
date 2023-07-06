//
//  AppDelegate.swift
//  loop
//
//  Created by Yecol Hsu on 03/08/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import PushKit
import UserNotifications
import HockeySDK
import IQKeyboardManagerSwift
import SwiftyJSON
import Fabric
import TwitterKit
import Instabug


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        
//        AVOSCloudCrashReporting.enable()
        AVOSCloud.setServiceRegion(.US);
        AVOSCloud.setApplicationId("6P22nVYj4LxDWIbPH18Nl1d0-MdYXbMMI", clientKey: "CAkV248oXda09OUM9BHssly3");
        AVOSCloud.setAllLogsEnabled(true)

        LPPost.registerSubclass()
        LPComment.registerSubclass()
        AVUser.registerSubclass()
        LPBadge.registerSubclass()
        LPPlace.registerSubclass()
        LPCheckin.registerSubclass()
        LPNotification.registerSubclass()
        PlusButtonSubclass.register();
        
        Instabug.start(withToken: "54c1a1759c1ff68c82b8c70e171b80d3", invocationEvent: .shake)
        Instabug.setCrashReportingEnabled(true);
        Instabug.setShakingThresholdForiPhone(1.5, foriPad: 0.5);

        // configure for hockey sdk
        BITHockeyManager.shared().configure(withIdentifier: "573abf65fdcb481b8fc932806b420fec")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation() // This line is obsolete in the crash only builds

        IQKeyboardManager.sharedManager().enable = true

        self.window?.tintColor = CL_GREEN_DEFAULT;
        UIApplication.shared.statusBarStyle = .lightContent

        if (UserDefaults.standard.object(forKey: "appid") == nil || UserDefaults.standard.object(forKey: "appid") as? String != AVOSCloud.getApplicationId()) {
            // differ app. logout force.
            AVUser.logOut();
            UserDefaults.standard.set(nil, forKey: "appid");
        }

        

        UITabBar.appearance().backgroundColor = UIColor.white

        self.window = UIWindow();
        self.window!.frame = UIScreen.main.bounds;
        self.window!.rootViewController = MainTabBarController();
        self.window!.makeKeyAndVisible();

        Fabric.with([Twitter.self])
        
        LPChat.invokeThisMethodInDidFinishLaunching();
        self.requestToRegisterRemoteNotification();

        return true
    }
    
    
    func requestToRegisterRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [UNAuthorizationOptions.alert, .badge, .sound], completionHandler: { granted, error in
                UIApplication.shared.registerForRemoteNotifications();
            })
            
            center.getNotificationSettings(completionHandler: {grant in ()});
        
            let types = [UIUserNotificationType.alert, .badge, .sound] as UIUserNotificationType;
            let settings = UIUserNotificationSettings(types: types, categories: nil);
            UIApplication.shared.registerUserNotificationSettings(settings);
            UIApplication.shared.registerForRemoteNotifications();
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        LPChat.invokeThisMethod(inApplicationWillResignActive: application);
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        LPChat.invokeThisMethod(inApplicationWillTerminate: application);
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken);
        LPChat.invokeThisMethodInDidRegisterForRemoteNotifications(withDeviceToken: deviceToken);
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let userInfoJson = JSON(userInfo)
        print("receive user push info:", userInfo)
        if (userInfoJson["action"] == "com.loop.push.action.FRIEND_ACCEPTED" || userInfoJson["action"] == "com.loop.push.action.FRIEND_REQUESTED") {
            let tabController = self.window!.rootViewController as! MainTabBarController;
            tabController.selectedIndex = 3;
        }
//        if (userInfoJson["action"] == "com.loop.push.action.BADGE_GRANT" ||
//            userInfoJson["action"] == "com.loop.push.action.BADGE_UPGRADED") {
//            let controller = self.window?.visibleViewController;
//            controller?.displayBadgeCongrats(badgeId: userInfoJson["badgeId"].stringValue)
//        }
        else{
            LPChat.invokeThisMethod(in: application, didReceiveRemoteNotification: userInfo);
        }
    }
    

    // notifications
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = JSON(notification.request.content.userInfo)
        print("get user push info:", userInfo)
        if (userInfo["action"] == "com.loop.push.action.FRIEND_ACCEPTED" || userInfo["action"] == "com.loop.push.action.FRIEND_REQUESTED") {
            let tabController = self.window!.rootViewController as! MainTabBarController;
            tabController.selectedIndex = 3;
        }
        else if(userInfo["action"] == "com.loop.push.action.REPORTED_POST_HANDLED"){
            let controller = self.window?.visibleViewController;
            controller?.displayAlertView("Your report on post is processed.");
        }
//        if (userInfo["action"] == "com.loop.push.action.BADGE_GRANT" ||
//                userInfo["action"] == "com.loop.push.action.BADGE_UPGRADED") {
//            let controller = self.window?.visibleViewController;
//            controller?.displayBadgeCongrats(badgeId: userInfo["badgeId"].stringValue);
//        }
        completionHandler(.sound);
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = JSON(response.notification.request.content.userInfo)
        print("receive user push info:", userInfo)
        if (userInfo["action"] == "com.loop.push.action.FRIEND_ACCEPTED" || userInfo["action"] == "com.loop.push.action.FRIEND_REQUESTED") {
            let tabController = self.window!.rootViewController as! MainTabBarController;
            tabController.selectedIndex = 3;
        }
        else if(userInfo["action"] == "com.loop.push.action.REPORTED_POST_HANDLED"){
            let controller = self.window?.visibleViewController;
            controller?.displayAlertView("Your report on post is processed.");
        }
//        if (userInfo["action"] == "com.loop.push.action.BADGE_GRANT" ||
//                userInfo["action"] == "com.loop.push.action.BADGE_UPGRADED") {
//            let controller = self.window?.visibleViewController;
//            controller?.displayBadgeCongrats(badgeId: userInfo["badgeId"].stringValue)
//        }
        completionHandler();
    }
}

