//
//  FeedApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FeedApi {
    var REF_FEED = Database.database().reference().child("feed")
    
    func fetchCountPost(userId: String,completion: @escaping (Int) -> Void) {
        REF_FEED.child(userId).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func observeFeed(userId: String, completion: @escaping (Post?,Int) -> Void) {
        REF_FEED.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            arraySnapshot.forEach({ (child) in
                let postId = child.key
                Api.Post.observePost(postId: postId, completion: { (post) in
                    completion(post, arraySnapshot.count)
                })
            })
        }
    }
    
    func deleteFeedPost(userId: String, postId: String) {
        REF_FEED.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            
            arraySnapshot.forEach({ (child) in
                
                if child.hasChild(postId) {
                    self.REF_FEED.child(userId).child(postId).removeValue()
                }
            })
        }
    }
}
