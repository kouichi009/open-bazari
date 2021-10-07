//
//  ChargeApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/05.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ChargeApi {
    var REF_MYCHARGE = Database.database().reference().child("myCharge")
    
    func fetchChargeCount(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYCHARGE.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func observeMyCharge(userId: String, completion: @escaping (Charge?, Int) -> Void) {
        REF_MYCHARGE.child(userId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            print("arayCount ", arraySnapshot.count)
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let charge = Charge.transformCharge(dict: dict, key: child.key)
                    completion(charge, arraySnapshot.count)
                } else {
                    completion(nil, arraySnapshot.count)
                }
            })
        }
    }
}
