//
//  Chat.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class Chat {
    var id: String?
    var messageText: String?
    var postId: String?
    var timestamp: Int?
    var date: String?
    var uid: String?
}

extension Chat {
    static func transformChat(dict: [String: Any], key: String) -> Chat {
        let chat = Chat()
        chat.messageText = dict["messageText"] as? String
        chat.id = key
        chat.postId = dict["postId"] as? String
        chat.timestamp = dict["timestamp"] as? Int
        chat.date = dict["date"] as? String
        chat.uid = dict["uid"] as? String

        
        return chat
    }
}
