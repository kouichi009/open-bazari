//
//  NotificationApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    var REF_MYNOTIFICATION = Database.database().reference().child("myNotification")
    var REF_EXIST_NOTIFICATION = Database.database().reference().child("existNotification")
    
    func observeExistNotification(uid: String, postId: String, type: String, currentUid: String, completion: @escaping (String?) -> Void) {
        
        REF_EXIST_NOTIFICATION.child(uid).child(currentUid).child(postId).child(type).observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            
            var notificationId: String?
            arraySnapshot.forEach({ (child) in
                notificationId = child.key
                completion(notificationId)
            })
            
            if notificationId == nil {
                completion(nil)
            }
        }
    }
    
    func observeChangeMyNotification(uid: String, completion: @escaping (Notification) -> Void) {
        
        REF_MYNOTIFICATION.child(uid).observe(.childChanged) { (snapshot) in
            
            let notificationId = snapshot.key
            
            self.observeNotification(notificationId: notificationId, completion: { (notification) in
                
                if let notification = notification {
                    completion(notification)
                }
            })
        }
    }
    
    func observeExistFollowNotification(withUid: String, currentUid: String, completion: @escaping (Bool) -> Void) {
        
        REF_MYNOTIFICATION.child(withUid).child("\(withUid)-\(currentUid)").observeSingleEvent(of: .value) { (snapshot) in
            
            completion(snapshot.exists())
        }
    }
    
    func fetchNotificationCount(uid: String, completion: @escaping (Int) -> Void) {
        
        REF_MYNOTIFICATION.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func observeNotificationAdd(uid: String, completion: @escaping (Notification) -> Void) {
        
        REF_MYNOTIFICATION.child(uid).queryOrdered(byChild: "timestamp").observe( .childAdded) { (snapshot) in
            
            
            if let dict = snapshot.value as? [String: Any] {
                
                let notiId = snapshot.key
                
                self.observeNotification(notificationId: notiId, completion: { (notification) in
                    
                    if let notification = notification {
                        completion(notification)
                    }
                })
            }
            
        }
    }
    
    func observeNotifications(uid: String, completion: @escaping (Notification, Int) -> Void) {
        
        REF_MYNOTIFICATION.child(uid).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                
                let notificationId = child.key
                self.observeNotification(notificationId: notificationId, completion: { (notification) in
                    
                    if let notification = notification {
                        completion(notification, arraySnapshot.count)
                    }
                })
            })
        }
    }
        
        func observeNotification(notificationId: String, completion: @escaping (Notification?) -> Void) {
            
            REF_NOTIFICATION.child(notificationId).observeSingleEvent(of: .value) { (snapshot) in
                
                if let dict = snapshot.value as? [String: Any] {
                    
                    let notification = Notification.transform(dict: dict, key: snapshot.key)
                    completion(notification)
                } else {
                    completion(nil)
                }
            }
        }

    func sendNotification(token: String, message: String, block: @escaping (_ succeeded:Bool, _ error:Error?) -> Void)  {
        
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // firebase のクラウドメッセージタブのサーバーキーのトークン
        request.setValue("key=\(Config.firebaseServerKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        request.httpBody = "{\"to\":\"\(token)\",\"notification\":{\"body\":\"\(message)\",\"badge\":\"1\"}}".data(using: .utf8)
        
 //       request.httpBody = "{\"to\":\"\(token)\",\"notification\":{\"title\":\"\(message)\",\"body\":\"\(body)\",\"badge\":\"1\"}}".data(using: .utf8)
        
//        request.httpBody = "{\"to\":\"\(token)\",\"notification\":{\"title\":\"\(message)\",\"badge\":\"1\"}}".data(using: .utf8)
//        request.httpBody = "{\"to\":\"\(token)\",\"notification\":{\"title\":\"\(message)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                block(false, nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                block(false, nil)
            } else {
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                block(true, nil)
            }
            
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
