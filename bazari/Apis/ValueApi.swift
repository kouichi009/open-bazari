//
//  ValueApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/29.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ValueApi {
    
    var REF_VALUE = Database.database().reference().child("value")
    var REF_MYVALUE = Database.database().reference().child("myValue")
    
    func observeValue(id: String, completion: @escaping (Value?) -> Void) {
        
        REF_VALUE.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let value = Value.transformValue(dict: dict, key: snapshot.key)
                completion(value)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchUserValues(userId: String, completion: @escaping (Value?, Int) -> Void) {

        REF_MYVALUE.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            print("arayCount ", arraySnapshot.count)
            arraySnapshot.forEach({ (child) in
                
                let id = child.key
                self.observeValue(id: id, completion: { (value) in
                    completion(value, arraySnapshot.count)
                })
            })
        }
    }
}
