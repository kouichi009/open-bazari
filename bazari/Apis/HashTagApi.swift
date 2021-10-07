//
//  HashTagApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class HashTagApi {
    var REF_HASHTAG = Database.database().reference().child("hashTag")

    func observeHashTagPosts(withTag tag: String, completion: @escaping (Post?, Int) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                let postId = child.key
                Api.Post.observePost(postId: postId, completion: { (post) in
                    completion(post, arraySnapshot.count)
                })
            })
        }
    }
    
    func deleteHashTag(postId: String) {
        
        REF_HASHTAG.observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            
            arraySnapshot.forEach({ (child) in
                
                if child.hasChild(postId) {
                    self.REF_HASHTAG.child(child.key).child(postId).removeValue()
                }
            })
        }
    }
}
