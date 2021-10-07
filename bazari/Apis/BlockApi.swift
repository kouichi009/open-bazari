//
//  BlockApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class BlockApi {
    let REF_BLOCKED = Database.database().reference().child("blocked")
    let REF_COMPLAINS = Database.database().reference().child("complains")

    func isBlocked(currentUid: String, userId: String, completion: @escaping (Bool) -> Void) {
        
        REF_BLOCKED.child(currentUid).child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
