//
//  Address.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class Address {
    
    var id: String?
    var seiKanji: String?
    var meiKanji: String?
    var seiKana: String?
    var meiKana: String?
    var phoneNumber: String?
    var postalCode: String?
    var prefecure: String?
    var city: String?
    var tyou: String?
    var building: String?
    var creditcard_Exist: Bool?
}

extension Address {
    static func transformAddress(dict: [String: Any], key: String) -> Address {
        let address = Address()
        address.id = key
        address.seiKanji = dict["seiKanji"] as? String
        address.meiKanji = dict["meiKanji"] as? String
        address.seiKana = dict["seiKana"] as? String
        address.meiKana = dict["meiKana"] as? String
        address.phoneNumber = dict["phoneNumber"] as? String
        address.postalCode = dict["postalCode"] as? String
        address.prefecure = dict["prefecture"] as? String
        address.city = dict["city"] as? String
        address.tyou = dict["tyou"] as? String
        address.building = dict["building"] as? String
        address.creditcard_Exist = dict["creditcard_Exist"] as? Bool
        return address
    }
}
