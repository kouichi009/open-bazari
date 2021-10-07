//
//  MyLikingPostsApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/31.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase


class MyLikingPostsApi {
    
    var REF_MYLIKING_POSTS =
        Database.database().reference().child("myLikingPosts")
    
    func fetchCountMySellPosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYLIKING_POSTS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    func observeMyAllPosts(userId: String, completion: @escaping (Post?,Int) -> Void) {
        
        REF_MYLIKING_POSTS.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                
                let postId = child.key
                Api.Post.observePost(postId: postId, completion: { (post) in
                    
                        completion(post, arraySnapshot.count)
                })
            })
        }
    }
    
    func deleteMyLikingPost(postId: String) {
        
        REF_MYLIKING_POSTS.observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                let userId = child.key
                
                if child.hasChild(postId) {
                    self.REF_MYLIKING_POSTS.child(userId).child(postId).removeValue()
                }
            })
        }
    }
}
