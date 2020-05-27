//
//  MYUPushManager.swift
//
//  Created by Dmitry Smirnov on 1/02/2019.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase

// MARK: - PushManagerDelegate

protocol PushManagerDelegate: class {
    
    func pushManagerDidReceiveMessage(payload: [AnyHashable: Any])
    func pushManagerDidTappedMessage(payload: [AnyHashable: Any])
}

// MARK: - PushManager

class MUPushManager: NSObject {
    
    weak var delegate: PushManagerDelegate?
    
    var registrationToken: String?
    
    // MARK: - Private properties
    
    private var deviceToken: Data?
    
    // MARK: - Public methods

    func setup(with application: UIApplication) {
        
        FirebaseApp.configure()
        
        if #available(iOS 10, *) {
            
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(
                
                options           : [.alert, .badge, .sound],
                
                completionHandler : { granted, error in
                    
                    if granted {
                        
                        application.registerForRemoteNotifications()
                    }
                }
            )
            
        } else {
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
            
            application.registerForRemoteNotifications()
        }
        
        Messaging.messaging().delegate = self
    }
    
    func updateDeviceToken(with deviceToken: Data) {
        
        self.deviceToken = deviceToken
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func showNotification(title: String, subtitle: String = "", body: String) {
        
        if #available(iOS 10, *) {
            
            let content = UNMutableNotificationContent()
            
            content.title = title
            content.body = body
            content.subtitle = subtitle
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
            
            let notification = UILocalNotification()
            
            notification.alertBody = "\(title)\n\(subtitle)\n\(body)"
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension MUPushManager: UNUserNotificationCenterDelegate {
    
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
    
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        delegate?.pushManagerDidTappedMessage(payload: response.notification.request.content.userInfo)
        
        Log.details("\(response)")
    }
}

// MARK: - MessagingDelegate

extension MUPushManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        registrationToken = fcmToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        delegate?.pushManagerDidReceiveMessage(payload: remoteMessage.appData)
    }
}
