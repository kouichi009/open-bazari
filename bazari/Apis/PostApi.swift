//
//  PostApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SVProgressHUD

class PostApi {
    var REF_POSTS = Database.database().reference().child("posts")
    
    func fetchCountPost(completion: @escaping (Int) -> Void) {
        REF_POSTS.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            completion(Int(snapshot.childrenCount))
        }
    }
    
    //.childAdded にqueryLimitedを使ってはいけない　理由: https://stackoverflow.com/questions/39736714/in-firebase-ios-sdk-childadded-is-triggered-every-time-a-child-is-deleted-how
    func observePostsAdded(completion: @escaping (Post?) -> Void) {
        
        REF_POSTS.queryOrdered(byChild: "timestamp").observe( .childAdded) { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                
                print("post.isCancel ", post.isCancel)
                //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                if let _ = post.isCancel {
                    completion(nil)
                } else {
                    completion(post)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func observeTopPosts(page: Int, completion: @escaping (Post?,Int) -> Void) {
        REF_POSTS.queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(page)).observeSingleEvent(of: .value, with: {
            snapshot in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            print("arayCount ", arraySnapshot.count)
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post.transformPostPhoto(dict: dict, key: child.key)
                    //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                    if let _ = post.isCancel {
                        completion(nil, arraySnapshot.count)
                    } else {
                        completion(post,arraySnapshot.count)
                    }
                } else {
                    completion(nil, arraySnapshot.count)
                }
            })
        })
    }
    
    func observeAllPosts(completion: @escaping (Post?,Int) -> Void) {
        
        REF_POSTS.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            if let arraySnapshot = (snapshot.children.allObjects as? [DataSnapshot])?.reversed() {
                
                arraySnapshot.forEach({ (child) in
                    if let dict = child.value as? [String: Any] {
                        let post = Post.transformPostPhoto(dict: dict, key: child.key)
                        
                        //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                        if let _ = post.isCancel {
                            completion(nil, arraySnapshot.count)
                        } else {
                            completion(post, arraySnapshot.count)
                        }
                    } else {
                        completion(nil, arraySnapshot.count)
                    }
                })
            }
        }
    }
    
    func observePost(postId: String, completion: @escaping (Post?) -> Void) {
        REF_POSTS.child(postId).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                
                //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                if let _ = post.isCancel {
                    completion(nil)
                } else {
                    completion(post)
                }
                
            } else {
                completion(nil)
            }
        })
    }
    
    func observeRemovePost(completion: @escaping (Post?) -> Void) {
        REF_POSTS.observe( .childRemoved) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                
                //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                if let _ = post.isCancel {
                    completion(nil)
                } else {
                    completion(post)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func observeChangePost(completion: @escaping (Post?) -> Void) {
        REF_POSTS.observe(.childChanged) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                if let _ = post.isCancel {
                    completion(nil)
                } else {
                    completion(post)
                }
            }  else {
                completion(nil)
            }
        }
    }
    
    
    //likeボタンを押したら呼ばれる
    func incrementLikes(post: Post, onSuccess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.Post.REF_POSTS.child(post.id!)
        //複数人に同時にボタンをおされても大丈夫なようにするメソッドrunTransactionBlock
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post2 = currentData.value as? [String : AnyObject], let uid = Api.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post2["likes"] as? [String : Bool] ?? [:]
                var likeCount = post2["likeCount"] as? Int ?? 0
                let timestamp = Int(Date().timeIntervalSince1970)
                
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                    
                    Api.MyLikePosts.REF_MYLIKING_POSTS.child((Api.User.CURRENT_USER?.uid)!).child(post.id!).setValue(NSNull())
                    
                } else {
                    likeCount += 1
                    likes[uid] = true
                    Api.MyLikePosts.REF_MYLIKING_POSTS.child((Api.User.CURRENT_USER?.uid)!).child(post.id!).updateChildValues(["timestamp": timestamp])
                }
                post2["likeCount"] = likeCount as AnyObject?
                post2["likes"] = likes as AnyObject?
                
                currentData.value = post2
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let pos = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
                onSuccess(pos)
            }
        }
    }
    
    func deletePost(userId: String, postId: String, completion: @escaping () -> Void) {
        
        SVProgressHUD.show()
        Api.HashTag.deleteHashTag(postId: postId)
        Api.MySellPosts.REF_MYSELL.child(userId).child(postId).removeValue()
        Api.Comment.deleteComments(postId: postId)
        Api.MyCommentPosts.deleteMyCommentingPost(postId: postId)
        Api.MyLikePosts.deleteMyLikingPost(postId: postId)
        Api.MyPosts.REF_MYPOSTS.child(userId).child(postId).removeValue()
        Api.Feed.deleteFeedPost(userId: userId, postId: postId)
        REF_POSTS.child(postId).removeValue { (error, ref) in
            SVProgressHUD.dismiss()
            completion()
        }
    }
    
}
