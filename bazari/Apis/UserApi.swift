//
//  UserApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserApi {
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUser(withId id: String, completion: @escaping (UserModel?) -> Void) {
        REF_USERS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let usermodel = UserModel.transformUser(dict: dict, key: snapshot.key)
                
                //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                if let _ = usermodel.isCancel {
                    completion(nil)
                } else {
                    completion(usermodel)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    func observeAllUsers(completion: @escaping (UserModel?,Int) -> Void) {
        REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let usermodel = UserModel.transformUser(dict: dict, key: child.key)
                    
                    //退会済みユーザーの投稿の場合、表示させないため、nilを返す
                    if let _ = usermodel.isCancel {
                        completion(nil, arraySnapshot.count)
                    } else {
                        completion(usermodel, arraySnapshot.count)
                    }
                    
                } else {
                    completion(nil, arraySnapshot.count)
                }
            })
            
            if arraySnapshot.count == 0 {
                completion(nil,0)
            }
        }
    }
    
    
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        
        return nil
    }
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }
    
    
    /////////////////////////(今回は使っていない。)PeopleViewController///////////////////////////////////
    
    func observeUsersPage(page: Int, completion: @escaping (UserModel,Int) -> Void) {
        REF_USERS.queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(page)).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot])
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let usermodel = UserModel.transformUser(dict: dict, key: child.key)
                    completion(usermodel,arraySnapshot.count)
                }
            })
        }
    }
    
    
    func observeUserLoadMore(page: Int, completion: @escaping (UserModel,Int) -> Void) {
        REF_USERS.queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(page)).observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let usermodel = UserModel.transformUser(dict: dict, key: child.key)
                    completion(usermodel,arraySnapshot.count)
                }
            })
        }
    }
    
    /////////////////////////PeopleViewController///////////////////////////////////
    
}
