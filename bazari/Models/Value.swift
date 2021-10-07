//
//  Value.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/29.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class Value {
    var id: String?
    var postId: String?
    var valueStatus: String?
    var valueComment: String?
    var from: String?
    var type: String?
    var timestamp: Int?
}

extension Value {
    static func transformValue(dict: [String: Any], key: String) -> Value {
        let value = Value()
        value.id = key
        value.valueStatus = dict["valueStatus"] as? String
        value.valueComment = dict["valueComment"] as? String
        value.postId = dict["postId"] as? String
        value.from = dict["from"] as? String
        value.type = dict["type"] as? String
        value.timestamp = dict["timestamp"] as? Int
        return value
    }
}
