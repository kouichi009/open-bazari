//
//  ChatApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ChatApi {
    var REF_CHATS = Database.database().reference().child("chats")
    
    func observeChats(postId: String, completion: @escaping (Chat?,Int) -> Void) {
        REF_CHATS.child(postId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let chat = Chat.transformChat(dict: dict, key: child.key)
                    completion(chat, arraySnapshot.count)
                } else {
                    completion(nil, arraySnapshot.count)
                }
            })
            
            if arraySnapshot.count == 0 {
                completion(nil, 0)
            }
        }
    }
}
