//
//  BankInfo.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class BankInfo {
    var id: String?
    var accountNumber: Int?
    var accountType: String?
    var bank: String?
    var branchCode: Int?
    var firstName: String?
    var lastName: String?
}

extension BankInfo {
    static func transformBank(dict: [String: Any], key: String) -> BankInfo {
        let bankInfo = BankInfo()
        bankInfo.id = key
        bankInfo.accountNumber = dict["accountNumber"] as? Int
        bankInfo.accountType = dict["accountType"] as? String
        bankInfo.bank = dict["bank"] as? String
        bankInfo.branchCode = dict["branchCode"] as? Int
        bankInfo.firstName = dict["firstName"] as? String
        bankInfo.lastName = dict["lastName"] as? String
        return bankInfo
    }
}
