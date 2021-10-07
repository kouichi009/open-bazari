//
//  SoldOutApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class SoldOutApi {
    
    var REF_MY_SOLDOUT_POSTS =  Database.database().reference().child("mySoldOutPosts")
    var REF_SOLDOUT_POSTS = Database.database().reference().child("soldOutPosts")
    
    
    func fetchMySoldOutPosts(userId: String, completion: @escaping (Post?,Int) -> Void) {
        
        REF_MY_SOLDOUT_POSTS.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            if arraySnapshot.count == 0 {
                completion(nil,0)
            }
            arraySnapshot.forEach({ (child) in
              let postId = child.key
                
                self.observeSoldOutPost(postId: postId, completion: { (post) in
                    completion(post, arraySnapshot.count)
                })
            })
        }
    }
    
    func observeSoldOutPost(postId: String, completion: @escaping (Post?) -> Void) {
        REF_SOLDOUT_POSTS.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            } else {
                completion(nil)
            }
        }
    }
}
