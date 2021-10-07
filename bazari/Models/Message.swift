//
//  Message.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/24.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class Message {
    var id: String?
    var messageText: String?
    var timestamp: Int?
    var uid: String?
    var isRead: Bool?
    var type: String?
    var username: String?
}

extension Message {
    static func transformMessage(dict: [String: Any], key: String) -> Message {
        let message = Message()
        message.id = key
        message.timestamp = dict["timestamp"] as? Int
        message.uid = dict["uid"] as? String
        message.messageText = dict["messageText"] as? String
        message.isRead = dict["isRead"] as? Bool
        message.type = dict["type"] as? String
        
        return message
    }
}
