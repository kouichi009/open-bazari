
//
//  BankTransferDateApi.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/04.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class BankTransferDateApi {
    var REF_BANK_TRANSFER_DATES = Database.database().reference().child("bankTransferDates")
    
    func observeBankTrasDate(year: String, month_date: String, uid: String, completion: @escaping (BankTransDate?) -> Void) {
        
        REF_BANK_TRANSFER_DATES.child(year).child(month_date).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let bankTrasDate = BankTransDate.transformBankTrans(dict: dict, key: snapshot.key)
                completion(bankTrasDate)
            } else {
                
                completion(nil)
            }
        }
    }
}
