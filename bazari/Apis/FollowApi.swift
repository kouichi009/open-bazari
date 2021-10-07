//
//  FollowApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FollowApi {
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    
    //followしてるかどうか
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            REF_FOLLOWERS.child(userId).child(currentUid).observeSingleEvent(of: .value, with: {
                snapshot in
                if let _ = snapshot.value as? NSNull {
                    completed(false)
                } else {
                    completed(true)
                }
            })
        } else {
            completed(false)
        }
        
    }
    
    
    //フォローしたら呼ばれる
    func followAction(withUser id: String) {
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    
                    if let value = dict[key] as? [String: Any] {
                        let timestampPost = value["timestamp"] as! Int
                        //Feedノードに追加し、Home2ViewContollerにもpostが追加される
                        Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(key).setValue(["timestamp": timestampPost])
                    }
                    
                }
            }
        })
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(true)
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        //ActivityのNotificationにふぉろーされたとこを通知する。
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
        
        Api.Notification.observeExistFollowNotification(withUid: id, currentUid: currentUid) { (isExist) in
            
            if !isExist {
                let newNotificationReference = Api.Notification.REF_NOTIFICATION.child("\(id)-\(currentUid)")
                newNotificationReference.setValue(["checked": false, "from": Api.User.CURRENT_USER!.uid, "to": id, "objectId": currentUid, "type": "follow", "timestamp": timestamp, "segmentType": Config.you])
                
                let myNotificationReference = Api.Notification.REF_MYNOTIFICATION.child(id)
                myNotificationReference.child("\(id)-\(currentUid)").updateChildValues(["timestamp": timestamp])
            }
        }
    }
    
    func unFollowAction(withUser id: String) {
        print(Api.User.CURRENT_USER?.uid)
        print(id)
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    
                    print(key)
                    Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        })
        
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(NSNull())
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
    }
    
    //プロフィールに表示するフォローしてる数を表示させるため、フォロー数をカウントする
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
        
    }
    //プロフィールに表示するフォロワー数を表示させるため、フォロワー数をカウントする
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
        
    }
    
    //ここ再チェック　テーブルにデータがないとき、arraySnapshot.count == 0の中を走るかどうか
    //アカウント削除した時によばれる
    func observeDeleteFollow(userId: String ,completion: @escaping (String, Int) -> Void) {
        REF_FOLLOWING.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                let resultUid = child.key
                completion(resultUid, arraySnapshot.count)
            })
            
            if arraySnapshot.count == 0 {
                completion("", 0)
            }
        }
    }
    
    //ここ再チェック　テーブルにデータがないとき、arraySnapshot.count == 0の中を走るかどうか
    //アカウント削除した時によばれる
    func observeDeleteFollower(userId: String ,completion: @escaping (String, Int) -> Void) {
        REF_FOLLOWERS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                let resultUid = child.key
                completion(resultUid, arraySnapshot.count)
            })
            
            if arraySnapshot.count == 0 {
                completion("", 0)
            }
        }
    }
}
