//
//  BankInfoApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SVProgressHUD

class BankInfoApi {
    
    var REF_MYBANK = Database.database().reference().child("myBank")
    
    func observeMyBank(userId: String, completion: @escaping (BankInfo?) -> Void) {
        
        REF_MYBANK.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dict = snapshot.value as? [String: Any] {
                let bankInfo = BankInfo.transformBank(dict: dict, key: snapshot.key)
                completion(bankInfo)
            } else {
                completion(nil)
            }
            
        }
    }
}
