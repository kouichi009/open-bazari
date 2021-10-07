//
//  MyPostsApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class MyPostsApi {
    var REF_MYPOSTS = Database.database().reference().child("myPosts")

    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYPOSTS.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    func observeMyAllPosts(userId: String, completion: @escaping (Post?, Int) -> Void) {
        
        REF_MYPOSTS.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                Api.Post.observePost(postId: child.key, completion: { (post) in
                    
                    completion(post, arraySnapshot.count)
                    
                })
            })
        }
    }
    
    func fetchMyPosts(userId: String, page: Int, completion: @escaping (Post?, Int) -> Void) {
        REF_MYPOSTS.child(userId).queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(page)).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                Api.Post.observePost(postId: child.key, completion: { (post) in
                    
                        completion(post, arraySnapshot.count)
                    
                })
            })
        }
    }
   
}
