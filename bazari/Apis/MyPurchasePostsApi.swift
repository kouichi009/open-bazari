//
//  MyPurchasePostsApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/31.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MyPurchasePostsApi {
    var REF_MYPURCHASE = Database.database().reference().child("myPurchasePosts")
    
    func fetchCountMyPurchasePosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYPURCHASE.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    func observeMyAllPosts(userId: String, completion: @escaping (Post?,Int) -> Void) {
        
        REF_MYPURCHASE.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                
                let postId = child.key
                Api.Post.observePost(postId: postId, completion: { (post) in
                    
                    completion(post, arraySnapshot.count)
                })
            })
        }
    }
    
    func observeChangeMyPurchase(userId: String, completion: @escaping (Post?) -> Void) {
        
        REF_MYPURCHASE.child(userId).observe( .childChanged) { (snapshot) in
            
            let postId = snapshot.key
            Api.Post.observePost(postId: postId, completion: { (post) in
                    completion(post)
                
            })
        }
    }
}
