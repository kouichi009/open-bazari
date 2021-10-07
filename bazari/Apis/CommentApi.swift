//
//  CommentApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    var REF_COMMENTS = Database.database().reference().child("comments")
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    
    func fetchCountComment(completion: @escaping (Int) -> Void) {
        REF_POST_COMMENTS.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            completion(Int(snapshot.childrenCount))
        }
    }
    
    
    func observePostComments(postId: String, completion: @escaping (Comment?, Int) -> Void) {
        REF_POST_COMMENTS.child(postId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
            arraySnapshot.forEach({ (child) in
                let commentId = child.key
                self.observeComment(commentId: commentId, completion: { (comment) in
                    completion(comment, arraySnapshot.count)
                })
            })
            
            if arraySnapshot.count == 0 {
                completion(nil, 0)
            }
        }
    }
    
    func observeComment(commentId: String, completion: @escaping (Comment?) -> Void) {
        REF_COMMENTS.child(commentId).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let comment = Comment.transformComment(dict: dict, key: commentId)
                
                //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                if let _ = comment.isCancel {
                    completion(nil)
                } else {
                    completion(comment)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    func cancelMyComments(currentUid: String) {
        
        REF_COMMENTS.observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
            arraySnapshot.forEach({ (child) in
                let commentId = child.key
                if let dict = child.value as? [String: Any] {
                    let comment = Comment.transformComment(dict: dict, key: commentId)
                    if comment.uid == currentUid {
                        self.REF_COMMENTS.child(commentId).updateChildValues(["isCancel": true])
                    }
                }
            })
        }
    }
    
    func deleteComments(postId: String) {
        
        REF_POST_COMMENTS.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
            arraySnapshot.forEach({ (child) in
                
                let commentId = child.key
                self.REF_COMMENTS.child(commentId).removeValue()
                self.REF_POST_COMMENTS.child(postId).child(commentId).removeValue()
            })
        }
    }
}
