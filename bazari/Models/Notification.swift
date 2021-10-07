//
//  Notification.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/31.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation


class Notification {
    var from: String?
    var to: String?
    var objectId: String?
    var commentId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
    var checked: Bool?
    var segmentType: String?
}

extension Notification {
    static func transform(dict: [String: Any], key: String) -> Notification {
        let notification = Notification()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.from = dict["from"] as? String
        notification.to = dict["to"] as? String
        if let checked = dict["checked"] as? Bool {
            notification.checked = checked   //true
        }
        
        if let commentId = dict["commentId"] as? String {
            notification.commentId = commentId
        }
        notification.segmentType = dict["segmentType"] as? String
        
        return notification
    }
}


