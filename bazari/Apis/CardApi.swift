//
//  CardApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/30.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CardApi {
    var REF_CARDS = Database.database().reference().child("cards")
    func observeCard(withId id: String, completion: @escaping (Card?, Int) -> Void) {
        REF_CARDS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let card = Card.transformCard(dict: dict, key: child.key)
                    completion(card, arraySnapshot.count)
                }
            })
            
            if arraySnapshot.count == 0 {
                completion(nil, 0)
            }
            
            //            if let dict = snapshot.value as? [String: Any] {
            //                let card = Card.transformCard(dict: dict, key: snapshot.key)
            //                completion(card)
            //
            //            } else {
            //                completion(nil)
            //            }
        }
    }
}
