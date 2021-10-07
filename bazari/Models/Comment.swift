//
//  Comment.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment {
    var commentText: String?
    var uid: String?
    var id: String?
    var postId: String?
    var timestamp: Int?
    var isCancel: Bool?

    
    static func transformComment(dict: [String: Any], key: String) -> Comment {
        let comment = Comment()
        comment.id = key
        comment.postId = dict["postId"] as? String
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        comment.timestamp = dict["timestamp"] as? Int
        comment.isCancel = dict["isCancel"] as? Bool

        return comment
    }
    
}
