//
//  Charge.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/05.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation


class Charge {
    var id: String?
    var postId: String?
    var timestamp: Int?
    var titleStr: String?
    var price: Int?
    var type: String?
}

extension Charge {
    static func transformCharge(dict: [String: Any], key: String) -> Charge {
        let charge = Charge()
        charge.id = key
        charge.postId = dict["postId"] as? String
        charge.timestamp = dict["timestamp"] as? Int
        charge.titleStr = dict["title"] as? String
        charge.price = dict["price"] as? Int
        charge.type = dict["type"] as? String
        return charge
    }
}
