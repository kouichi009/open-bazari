//
//  Recent.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/24.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class Recent {
    
    var username: String?
    var chatRoomId: String?
    var id: String?
    var count: Int?
    var timestamp: Int?
    var lastMessage: String?
    var member: Dictionary<String, Any>?
    var uid: String?
    var withUserUserId: String?
}

extension Recent {
    static func transformRecent(dict: [String: Any], key: String) -> Recent {
        
        let recent = Recent()
        recent.id = key
        recent.chatRoomId = dict["chatRoomId"] as? String
        recent.count = dict["count"] as? Int
        recent.timestamp = dict["timestamp"] as? Int
        recent.lastMessage = dict["lastMessage"] as? String
        recent.member = dict["members"] as? Dictionary
        recent.uid = dict["uid"] as? String
        recent.withUserUserId = dict["withUserUserId"] as? String
        
        return recent
    }
}
