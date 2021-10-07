//
//  MessageApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/24.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MessageApi {
    var REF_MESSAGE = Database.database().reference().child("messages")
    
    func observeMessages(uid: String,chatRoomId: String, page: Int, completion: @escaping (Message, Int) -> Void) {
        REF_MESSAGE.child(uid).child(chatRoomId).observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let message = Message.transformMessage(dict: dict, key: child.key)
                    completion(message, arraySnapshot.count)
                }
            })
        }
    }
    
    func observeAddMessages(uid: String,chatRoomId: String, completion: @escaping (Message) -> Void) {
        REF_MESSAGE.child(uid).child(chatRoomId).observe(.childAdded) { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any] {
                let message = Message.transformMessage(dict: dict, key: snapshot.key)
                completion(message)
            }
            
        }
    }
    
    func fetchMessageCount(uid: String,chatRoomId: String, completion: @escaping (Int) -> Void) {
        REF_MESSAGE.child(uid).child(chatRoomId).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            let messageCount = arraySnapshot.count
            completion(messageCount)
        }
    }
}
