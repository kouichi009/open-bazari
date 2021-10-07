//
//  BankTransDate.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/05.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class BankTransDate {
    var accountNumber: Int?
    var accountType: String?
    var bank: String?
    var branchCode: Int?
    var firstName: String?
    var lastName: String?
    var price: Int?
    var applyDate: String?
}

extension BankTransDate {
    static func transformBankTrans(dict: [String: Any], key: String) -> BankTransDate {
        let bankTrans = BankTransDate()
        bankTrans.accountNumber = dict["accountNumber"] as? Int
        bankTrans.accountType = dict["accountType"] as? String
        bankTrans.bank = dict["bank"] as? String
        bankTrans.branchCode = dict["branchCode"] as? Int
        bankTrans.firstName = dict["firstName"] as? String
        bankTrans.lastName = dict["lastName"] as? String
        bankTrans.price = dict["price"] as? Int
        bankTrans.applyDate = dict["applyDate"] as? String

        return bankTrans
    }
}
