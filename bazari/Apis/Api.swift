//
//  Api.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var HashTag = HashTagApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var Notification = NotificationApi()
    static var Block = BlockApi()
    static var Message = MessageApi()
    static var Chat = ChatApi()
    static var Address = AddressApi()
    static var MyPurchasePosts = MyPurchasePostsApi()
    static var DraftPost = DraftPostApi()
    static var MySellPosts = MySellPostsApi()
    static var Value = ValueApi()
    static var MyLikePosts = MyLikingPostsApi()
    static var MyCommentPosts = MyCommentingPostsApi()
    static var SoldOut = SoldOutApi()
    static var BankInfo = BankInfoApi()
    static var Charge = ChargeApi()
    static var Card = CardApi()
    static var BankTransDate = BankTransferDateApi()
    static var Complain = ComplainApi()
    static var Brand = BrandApi()
}
