//
//  Post.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseAuth


class Post {
    var caption: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var comments: Dictionary<String, Any>?
    var isLiked: Bool?
    var commentCount: Int?
    var title: String?
    var brand: String?
    var category1: String?
    var category2: String?
    var price: Int?
    var shippedDateTimestamp: Int?
    var shipFrom: String?
    var shipPayer: String?
    var shipWay: String?
    var status: String?
    var ratios = [Dictionary<String, CGFloat>]()
    var timestamp: Int?
    var imageCount: Int?
    var imageUrls = [String]()
    var transactionStatus: String?
    var sellerShouldDo: String?
    var purchaserShouldDo: String?
    var purchaseDateTimestamp: Int?
    var purchaserUid: String?
    var shipDeadLine: String?
    var commisionRate: Double?
    var isCancel: Bool?
    var thumbnailUrl: String?
    var thumbnailRatio: Dictionary<String, CGFloat>?
}


extension Post {
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.isCancel = dict["isCancel"] as? Bool
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.comments = dict["comments"] as? Dictionary<String, Any>
        post.commentCount = dict["commentCount"] as? Int
        post.timestamp = dict["timestamp"] as? Int
        post.imageCount = dict["imageCount"] as? Int
        post.title = dict["title"] as? String
        post.brand = dict["brand"] as? String
        post.category1 = dict["category1"] as? String
        post.category2 = dict["category2"] as? String
        post.price = dict["price"] as? Int
        post.shippedDateTimestamp = dict["shippedDateTimestamp"] as? Int
        post.shipFrom = dict["shipFrom"] as? String
        post.shipPayer = dict["shipPayer"] as? String
        post.shipWay = dict["shipWay"] as? String
        post.status = dict["status"] as? String
        post.transactionStatus = dict["transactionStatus"] as? String
        post.purchaserShouldDo = dict["purchaserShouldDo"] as? String
        post.sellerShouldDo = dict["sellerShouldDo"] as? String
        post.purchaseDateTimestamp  = dict["purchaseDateTimestamp"] as? Int
        post.purchaserUid = dict["purchaserUid"] as? String
        post.shipDeadLine = dict["shipDeadLine"] as? String
        post.commisionRate = dict["commisionRate"] as? Double
        post.thumbnailUrl = dict["thumbnail"] as? String
        if let thumbRatio = dict["thumbnailRatio"] as? Dictionary<String, Any> {
            var dictionary = Dictionary<String, CGFloat>()
            let width = thumbRatio[Config.ratioWidthKey] as? Double
            let height = thumbRatio[Config.ratioHeightKey] as? Double
            dictionary[Config.ratioWidthKey] = CGFloat(width!)
            dictionary[Config.ratioHeightKey] = CGFloat(height!)
            post.thumbnailRatio = dictionary
        }
        
        switch post.imageCount! - 1 {
        case 0:
            let image0 = dict["image0"] as? String
            post.imageUrls.append(image0!)
            
            if let ratio0 = dict["ratio0"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio0[Config.ratioWidthKey] as? Double
                let height = ratio0[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
        case 1:
            let image0 = dict["image0"] as? String
            let image1 = dict["image1"] as? String
            post.imageUrls.append(image0!)
            post.imageUrls.append(image1!)
            
            if let ratio0 = dict["ratio0"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio0[Config.ratioWidthKey] as? Double
                let height = ratio0[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
            if let ratio1 = dict["ratio1"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio1[Config.ratioWidthKey] as? Double
                let height = ratio1[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
        case 2:
            let image0 = dict["image0"] as? String
            let image1 = dict["image1"] as? String
            let image2 = dict["image2"] as? String
            post.imageUrls.append(image0!)
            post.imageUrls.append(image1!)
            post.imageUrls.append(image2!)
            
            if let ratio0 = dict["ratio0"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio0[Config.ratioWidthKey] as? Double
                let height = ratio0[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
            
            if let ratio1 = dict["ratio1"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio1[Config.ratioWidthKey] as? Double
                let height = ratio1[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            if let ratio2 = dict["ratio2"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio2[Config.ratioWidthKey] as? Double
                let height = ratio2[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
        case 3:
            let image0 = dict["image0"] as? String
            let image1 = dict["image1"] as? String
            let image2 = dict["image2"] as? String
            let image3 = dict["image3"] as? String
            post.imageUrls.append(image0!)
            post.imageUrls.append(image1!)
            post.imageUrls.append(image2!)
            post.imageUrls.append(image3!)
            
            if let ratio0 = dict["ratio0"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio0[Config.ratioWidthKey] as? Double
                let height = ratio0[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
            if let ratio1 = dict["ratio1"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio1[Config.ratioWidthKey] as? Double
                let height = ratio1[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
            
            if let ratio2 = dict["ratio2"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio2[Config.ratioWidthKey] as? Double
                let height = ratio2[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
            if let ratio3 = dict["ratio3"] as? Dictionary<String, Any> {
                var dictionary = Dictionary<String, CGFloat>()
                let width = ratio3[Config.ratioWidthKey] as? Double
                let height = ratio3[Config.ratioHeightKey] as? Double
                dictionary[Config.ratioWidthKey] = CGFloat(width!)
                dictionary[Config.ratioHeightKey] = CGFloat(height!)
                post.ratios.append(dictionary)
            }
            
        default:
            print("t")
        }
        
        
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.likes != nil {
                post.isLiked = post.likes![currentUserId] != nil
            }
            
        }
        return post
    }
    
    
    
    
    
}


