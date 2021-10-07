//
//  AppDelegate.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/14.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import IQKeyboardManagerSwift
import FBSDKCoreKit
import UserNotifications
import FirebaseMessaging
import Repro
import AFNetworking
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        configureStripe()
        
        let height = UIScreen.main.bounds.size.height
        
        if height < 600 {
            Config.isUnderIphoneSE = true
        }
        
        IQKeyboardManager.shared.enable = true
        //青色
        IQKeyboardManager.shared.toolbarTintColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        //真ん中の文字を消す
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        //Facebookログイン
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 and above
            // display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        
        application.registerForRemoteNotifications()
        
        
        #if DEBUG
        print("これはデバッグビルドですよ！")
        #else
        // Setup Repro
        Repro.setup("")
        // Start Recording
        Repro.startRecording()
        #endif
        
        
        //強制アップデートアラート
        let siren = Siren.shared
        siren.forceLanguageLocalization = Siren.LanguageType.japanese  // 日本語
        siren.alertType = .force  // 強制アップデートしか選択肢が無いオプション
        siren.checkVersion(checkType: .immediately)
        
        Messaging.messaging().delegate = self
        return true
    }
    
    // access server to wake up heroku server
    // エラー forbidden (403)が出るが、urlにアクセスできるだけでいいので、これでOK. herokuサーバーは起きる。
    func callHerokuServer() {
        let url = Config.herokuForStripeServerUrl
        AFHTTPSessionManager().get(url, parameters: nil, success: { (operation, responseObject) in
            print("Heroku起きた")
        }) { (operation, error) in
            //     print("AFHTTPaccess Failure", error.localizedDescription)
            print("Heroku起きた")
        }
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.setValue(fcmToken, forKey: "FCMToken")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func configureStripe() {
        
        //テスト用
        Stripe.setDefaultPublishableKey(Config.StripeApiKey)
        
    }
    
    //badge reset
    func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        resetBadge()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        callHerokuServer()
        
        resetBadge()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler()
    }
}

