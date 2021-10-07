//
//  UserModel.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
class UserModel {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
    var isPhoneAuth: Bool?
    var isEmailAuth: Bool?
    var isAppReview: Bool?
    var isCancel: Bool?
    var blocks: Dictionary<String, Any>?
    var loginType: String?
    var timestamp: Int?
    var totalValue: Int?
    var sun: Int?
    var cloud: Int?
    var rain: Int?
    var selfIntro: String?
    var fcmToken: String?
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.isCancel = dict["isCancel"] as? Bool
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.blocks = dict["blocks"] as? Dictionary<String, Any>
        user.isPhoneAuth = dict["isPhoneAuth"] as? Bool
        user.isEmailAuth = dict["isEmailAuth"] as? Bool
        user.isAppReview = dict["isAppReview"] as? Bool
        user.fcmToken = dict["fcmToken"] as? String
        user.id = key
        if let value = dict["value"] as? Dictionary<String, Any> {
            user.sun = value["sun"] as? Int
            user.cloud = value["cloud"] as? Int
            user.rain = value["rain"] as? Int
            
            user.totalValue = user.sun! + user.cloud! + user.rain!
        }

        user.selfIntro = dict[Config.selfIntroStr] as? String
        
        
        if let loginType = dict["loginType"] as? String {
            user.loginType = dict["loginType"] as? String
        } else {
            user.loginType = Config.LoginTypeLINE
        }
        user.timestamp = dict["timestamp"] as? Int
        return user
    }
}
