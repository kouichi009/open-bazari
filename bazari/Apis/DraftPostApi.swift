//
//  DraftPostApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SVProgressHUD

class DraftPostApi {
    
    var REF_MYDRAFTPOST = Database.database().reference().child("myDraftPost")
    var REF_DRAFTPOSTS = Database.database().reference().child("draftPosts")
    
    func fetchMyDraftCount(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYDRAFTPOST.child(userId).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func observeMyDraftPost(userId: String, completion: @escaping (Post?, Int) -> Void) {
        REF_MYDRAFTPOST.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                let draftPostId = child.key
                self.observeDraftPost(draftPostId: draftPostId, completion: { (post) in
                    completion(post, arraySnapshot.count)
                })
            })
        }
    }
    
    func observeDraftPost(draftPostId: String, completion: @escaping (Post?) -> Void) {
        REF_DRAFTPOSTS.child(draftPostId).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            } else {
                completion(nil)
            }
        }
    }
}
