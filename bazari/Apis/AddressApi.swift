//
//  AddressApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase


class AddressApi {
        var REF_ADDRESS = Database.database().reference().child("address")
    
    func observeAddress(userId: String, completion: @escaping (Address?) -> Void) {
        REF_ADDRESS.child(userId).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let address = Address.transformAddress(dict: dict, key: snapshot.key)
                completion(address)
            } else {
                completion(nil)
            }
        })
    }
}
