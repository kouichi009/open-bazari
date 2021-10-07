//
//  HelperService.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

protocol ReloadNotificationDelegate {
    func reloadNotification()
}

class HelperService {
    
    static var notiVC: NotificationViewController?
    
    static func draftPostDataToServer(tupleImages: [(image: UIImage, sort: Int)], ratios: [Dictionary<String, CGFloat>], imageCount: Int, title: String?, caption: String?, category1: String?, category2: String?, status: String?, shipPayer: String?, shipWay: String?, shipDate: String?, shipFrom: String?, price: Int?, brand: String?, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        
        var thumbnailUrl: String?
        var thumbnailRatioDict: Dictionary<String, CGFloat>?
        var imageUrls = [String]()
        
        var imageUrl_0: String?
        var imageUrl_1: String?
        var imageUrl_2: String?
        var imageUrl_3: String?
        
        
        uploadThumbnail(thumbnail: tupleImages[0].image, onSuccess: { (thumbUrl, thumbRatioDict) in
            thumbnailUrl = thumbUrl
            thumbnailRatioDict = thumbRatioDict
            setDatabaseToDraftPosts(thumbnailUrl: thumbnailUrl, thumbnailRatioDict: thumbnailRatioDict, imageUrls: imageUrls, ratios: ratios, imagesCount: imageCount, title: title, caption: caption, category1: category1, category2: category2, status: status, shipPayer: shipPayer, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFrom, price: price, brand: brand, onSuccess: onSuccess, onError: onError)
        }, onError: onError)
        
        var count = 0
        for tupleImage in tupleImages {
            uploadImage(tupleImage: tupleImage, onSuccess: { (tupleImageUrl) in
                
                switch tupleImageUrl.sort {
                case 0:
                    imageUrl_0 = tupleImageUrl.imageUrl
                case 1:
                    imageUrl_1 = tupleImageUrl.imageUrl
                    
                case 2:
                    imageUrl_2 = tupleImageUrl.imageUrl
                    
                case 3:
                    imageUrl_3 = tupleImageUrl.imageUrl
                    
                default:
                    print("t")
                }
                
                count += 1
                
                if count == tupleImages.count {
                    
                    switch tupleImages.count {
                    case 1:
                        imageUrls.append(imageUrl_0!)
                    case 2:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                    case 3:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                        imageUrls.append(imageUrl_2!)
                    case 4:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                        imageUrls.append(imageUrl_2!)
                        imageUrls.append(imageUrl_3!)
                        
                    default:
                        print("t")
                    }
                }
                
                if tupleImages.count == imageUrls.count {
                    
                    setDatabaseToDraftPosts(thumbnailUrl: thumbnailUrl, thumbnailRatioDict: thumbnailRatioDict, imageUrls: imageUrls, ratios: ratios, imagesCount: imageCount, title: title, caption: caption, category1: category1, category2: category2, status: status, shipPayer: shipPayer, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFrom, price: price, brand: brand, onSuccess: onSuccess, onError: onError)
                    
                }
            }, onError: onError)
        }
    }
    
    static func setDatabaseToDraftPosts(thumbnailUrl: String?, thumbnailRatioDict: Dictionary<String, CGFloat>?, imageUrls: [String], ratios: [Dictionary<String, CGFloat>], imagesCount: Int, title: String?, caption: String?,category1: String?, category2: String?, status: String?, shipPayer: String?, shipWay: String?, shipDate: String?, shipFrom: String?, price: Int?, brand: String?, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
     
        if thumbnailUrl != nil && imageUrls.count == imagesCount {
          
            let newDraftPostId = Api.DraftPost.REF_DRAFTPOSTS.childByAutoId().key
            let newDraftPostReference = Api.DraftPost.REF_DRAFTPOSTS.child(newDraftPostId!)
            let timestamp = Int(Date().timeIntervalSince1970)
            guard let currentUid = Api.User.CURRENT_USER?.uid else {
                onError()
                return
            }
            
            var thumbDict: Dictionary<String, CGFloat> = thumbnailRatioDict!
            let thumbDictWidth0 = thumbDict[Config.ratioWidthKey]
            let thumbDictHeight0 = thumbDict[Config.ratioHeightKey]
            
            switch (imagesCount - 1) {
            case 0:
                
                 let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "ratio0": ratios[0], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                 
                newDraftPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyDraftPostsDatabase(currentUid: currentUid, newDraftPostId: newDraftPostId!, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
            case 1:
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "ratio0": ratios[0], "ratio1": ratios[1], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
               
                newDraftPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyDraftPostsDatabase(currentUid: currentUid, newDraftPostId: newDraftPostId!, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
            case 2:
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "image2": imageUrls[2], "ratio0": ratios[0], "ratio1": ratios[1], "ratio2": ratios[2], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                
                newDraftPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyDraftPostsDatabase(currentUid: currentUid, newDraftPostId: newDraftPostId!, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
            case 3:
                 let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "image2": imageUrls[2], "image3": imageUrls[3], "ratio0": ratios[0], "ratio1": ratios[1], "ratio2": ratios[2], "ratio3": ratios[3], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                 
                newDraftPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyDraftPostsDatabase(currentUid: currentUid, newDraftPostId: newDraftPostId!, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
                
            default:
                print("t")
            }
            
        }
    }
    
     static func setMyDraftPostsDatabase(currentUid: String, newDraftPostId: String, timestamp: Int, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        let myDraftPostRef = Api.DraftPost.REF_MYDRAFTPOST.child(currentUid).child(newDraftPostId)
        myDraftPostRef.setValue(["timestamp": timestamp])
        
        onSuccess()
    }
    
    
    static func uploadDataToServer(tupleImages: [(image: UIImage, sort: Int)], ratios: [Dictionary<String, CGFloat>], imageCount: Int,title: String, caption: String, category1: String, category2: String, status: String, shipPayer: String, shipWay: String, shipDate: String, shipFrom: String, price: Int, brand: String?, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        var thumbnailUrl: String?
        var thumbnailRatioDict: Dictionary<String, CGFloat>?
        var imageUrls = [String]()
        
        var imageUrl_0: String?
        var imageUrl_1: String?
        var imageUrl_2: String?
        var imageUrl_3: String?
        
        
        
        uploadThumbnail(thumbnail: tupleImages[0].image, onSuccess: { (thumbUrl, thumbRatioDict) in
            thumbnailUrl = thumbUrl
            thumbnailRatioDict = thumbRatioDict
            
            setDatabaseToPosts(thumbnailUrl: thumbnailUrl, thumbnailRatioDict: thumbnailRatioDict, imageUrls: imageUrls, ratios: ratios, imagesCount: tupleImages.count, title: title, caption: caption, category1: category1, category2: category2, status: status, shipPayer: shipPayer, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFrom, price: price, brand: brand, onSuccess: onSuccess, onError: onError)
        }, onError: onError)
        
        
        var count = 0
        for tupleImage in tupleImages {
            uploadImage(tupleImage: tupleImage, onSuccess: { (tupleImageUrl) in
            
                switch tupleImageUrl.sort {
                case 0:
                    imageUrl_0 = tupleImageUrl.imageUrl
                case 1:
                    imageUrl_1 = tupleImageUrl.imageUrl

                case 2:
                    imageUrl_2 = tupleImageUrl.imageUrl

                case 3:
                    imageUrl_3 = tupleImageUrl.imageUrl

                default:
                    print("t")
                }
                
                count += 1
                
                if count == tupleImages.count {
                    
                    switch tupleImages.count {
                    case 1:
                        imageUrls.append(imageUrl_0!)
                    case 2:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                    case 3:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                        imageUrls.append(imageUrl_2!)
                    case 4:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                        imageUrls.append(imageUrl_2!)
                        imageUrls.append(imageUrl_3!)
                        
                    default:
                        print("t")
                    }
                }
                
                if tupleImages.count == imageUrls.count {
                    
                    setDatabaseToPosts(thumbnailUrl: thumbnailUrl, thumbnailRatioDict: thumbnailRatioDict, imageUrls: imageUrls, ratios: ratios, imagesCount: tupleImages.count, title: title, caption: caption, category1: category1, category2: category2, status: status, shipPayer: shipPayer, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFrom, price: price, brand: brand, onSuccess: onSuccess, onError: onError)
                    
                }
            }, onError: onError)
        }
    }
    
    static func uploadThumbnail(thumbnail: UIImage, onSuccess: @escaping (String, Dictionary<String, CGFloat>) -> Void, onError: @escaping() -> Void) {
        let imageName = NSUUID().uuidString // Unique string to reference image
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("posts").child(imageName)
        
        let resizeImage = resizeUIImageByWidth(image: thumbnail, width: 500)
        guard let data = UIImageJPEGRepresentation(resizeImage, 0.1) else {return}
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                onError()
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if let photoUrl = url?.absoluteString {
                    var dic: Dictionary<String, CGFloat> = [:]
                    let thumbnailWidthRatio = resizeImage.size.height / resizeImage.size.width
                    let thumbnailHeightRatio = resizeImage.size.width / resizeImage.size.height
                    dic[Config.ratioWidthKey] = thumbnailWidthRatio
                    dic[Config.ratioHeightKey] = thumbnailHeightRatio
                    
                    onSuccess(photoUrl, dic)
                }
            })
        }
    }
    
    /**
     * 横幅を指定してUIImageをリサイズする
     * @params image: 対象の画像
     * @params width: 基準となる横幅
     * @return 横幅をwidthに、縦幅はアスペクト比を保持したサイズにリサイズしたUIImage
     */
    static func resizeUIImageByWidth(image: UIImage, width: Double) -> UIImage {
        
        // 元の画像の横幅がwidth(ex: サムネ用500))以下の場合は、リサイズしない。(500以下という場合はあまりありえないと思う。)
        if Double(image.size.width) < width {
            return image
        }
        // オリジナル画像のサイズから、アスペクト比を計算
        let aspectRate = image.size.height / image.size.width
        // リサイズ後のWidthをアスペクト比を元に、リサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectRate))
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    
    static func uploadImage(tupleImage: (image: UIImage, sort: Int), onSuccess: @escaping ((imageUrl: String, sort: Int)) -> Void, onError: @escaping() -> Void) {
        let imageName = NSUUID().uuidString // Unique string to reference image
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("posts").child(imageName)
        
        let resizeWidthValue: Double = 1500
        var newImage = tupleImage.image
        //もし、横幅が1500以上であれば、リサイズする。
        //大きすぎる画像だとAndroidで表示させたときに画像が横向きに表示されてしまうことがある。
        //参考Youtube: https://www.youtube.com/watch?v=Tp8JYA1X-7c&feature=youtu.be
        if Double(tupleImage.image.size.width) > resizeWidthValue {
            newImage = resizeUIImageByWidth(image: tupleImage.image, width: resizeWidthValue)
        }
        
        guard let data = UIImageJPEGRepresentation(newImage, 0.1) else {return}
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                onError()
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if let photoUrl = url?.absoluteString {
                
                    let tupleImageUrl: (imageUrl: String, sort: Int) = (imageUrl: photoUrl, sort: tupleImage.sort)
                    onSuccess(tupleImageUrl)
                }
            })
        }
    }
    
    static func setDatabaseToPosts(thumbnailUrl: String?, thumbnailRatioDict: Dictionary<String, CGFloat>?, imageUrls: [String], ratios: [Dictionary<String, CGFloat>], imagesCount: Int, title: String, caption: String,category1: String, category2: String, status: String, shipPayer: String, shipWay: String, shipDate: String, shipFrom: String, price: Int, brand: String?, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
       
        if thumbnailUrl != nil && imageUrls.count == imagesCount {
           
            let newPostId = Api.Post.REF_POSTS.childByAutoId().key
            let newPostReference = Api.Post.REF_POSTS.child(newPostId!)
            let timestamp = Int(Date().timeIntervalSince1970)
            guard let currentUid = Api.User.CURRENT_USER?.uid else {
                onError()
                return
            }
            
            var thumbDict: Dictionary<String, CGFloat> = thumbnailRatioDict!
            let thumbDictWidth = thumbDict[Config.ratioWidthKey]
            let thumbDictHeight = thumbDict[Config.ratioHeightKey]
            
            switch (imagesCount - 1) {
            case 0:
                var dic0: Dictionary<String, CGFloat> = ratios[0]
                let ratioWidth0 = dic0[Config.ratioWidthKey]
                let ratioHeight0 = dic0[Config.ratioHeightKey]
                
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth, Config.ratioHeightKey: thumbDictHeight], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "ratio0": [Config.ratioWidthKey: ratioWidth0, Config.ratioHeightKey: ratioHeight0],  "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                newPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyPostsDatabase(currentUid: currentUid, newPostId: newPostId!, title: title, caption: caption, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
            case 1:
                var dic0: Dictionary<String, CGFloat> = ratios[0]
                let ratioWidth0 = dic0[Config.ratioWidthKey]
                let ratioHeight0 = dic0[Config.ratioHeightKey]
                
                var dic1: Dictionary<String, CGFloat> = ratios[1]
                let ratioWidth1 = dic1[Config.ratioWidthKey]
                let ratioHeight1 = dic1[Config.ratioHeightKey]
                
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth, Config.ratioHeightKey: thumbDictHeight], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "ratio0": [Config.ratioWidthKey: ratioWidth0, Config.ratioHeightKey: ratioHeight0], "ratio1": [Config.ratioWidthKey: ratioWidth1, Config.ratioHeightKey: ratioHeight1], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                newPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyPostsDatabase(currentUid: currentUid, newPostId: newPostId!, title: title, caption: caption, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })

            case 2:
                var dic0: Dictionary<String, CGFloat> = ratios[0]
                let ratioWidth0 = dic0[Config.ratioWidthKey]
                let ratioHeight0 = dic0[Config.ratioHeightKey]
                
                var dic1: Dictionary<String, CGFloat> = ratios[1]
                let ratioWidth1 = dic1[Config.ratioWidthKey]
                let ratioHeight1 = dic1[Config.ratioHeightKey]
                
                var dic2: Dictionary<String, CGFloat> = ratios[2]
                let ratioWidth2 = dic2[Config.ratioWidthKey]
                let ratioHeight2 = dic2[Config.ratioHeightKey]
                
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio":  [Config.ratioWidthKey: thumbDictWidth, Config.ratioHeightKey: thumbDictHeight], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "image2": imageUrls[2], "ratio0": [Config.ratioWidthKey: ratioWidth0, Config.ratioHeightKey: ratioHeight0], "ratio1": [Config.ratioWidthKey: ratioWidth1, Config.ratioHeightKey: ratioHeight1], "ratio2": [Config.ratioWidthKey: ratioWidth2, Config.ratioHeightKey: ratioHeight2], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                newPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyPostsDatabase(currentUid: currentUid, newPostId: newPostId!, title: title, caption: caption, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })

            case 3:
                
                var dic0: Dictionary<String, CGFloat> = ratios[0]
                let ratioWidth0 = dic0[Config.ratioWidthKey]
                let ratioHeight0 = dic0[Config.ratioHeightKey]
                
                var dic1: Dictionary<String, CGFloat> = ratios[1]
                let ratioWidth1 = dic1[Config.ratioWidthKey]
                let ratioHeight1 = dic1[Config.ratioHeightKey]
                
                var dic2: Dictionary<String, CGFloat> = ratios[2]
                let ratioWidth2 = dic2[Config.ratioWidthKey]
                let ratioHeight2 = dic2[Config.ratioHeightKey]
                
                var dic3: Dictionary<String, CGFloat> = ratios[3]
                let ratioWidth3 = dic3[Config.ratioWidthKey]
                let ratioHeight3 = dic3[Config.ratioHeightKey]
                
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth, Config.ratioHeightKey: thumbDictHeight], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount,"image0": imageUrls[0], "image1": imageUrls[1], "image2": imageUrls[2], "image3": imageUrls[3], "ratio0": [Config.ratioWidthKey: ratioWidth0, Config.ratioHeightKey: ratioHeight0], "ratio1": [Config.ratioWidthKey: ratioWidth1, Config.ratioHeightKey: ratioHeight1], "ratio2": [Config.ratioWidthKey: ratioWidth2, Config.ratioHeightKey: ratioHeight2],"ratio3": [Config.ratioWidthKey: ratioWidth3, Config.ratioHeightKey: ratioHeight3], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                newPostReference.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        setMyPostsDatabase(currentUid: currentUid, newPostId: newPostId!, title: title, caption: caption, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })

                
            default:
                print("t")
            }
        }
    }
    
    
    static func setMyPostsDatabase(currentUid: String, newPostId: String, title: String, caption: String, timestamp: Int, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUid).child(newPostId)
        myPostRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                onError()
                return
            }
        })
        
        let mySellPostsRef = Api.MySellPosts.REF_MYSELL.child(currentUid).child(newPostId)
        mySellPostsRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                onError()
                return
            }
        })
        
        
        var titleStr = title
        let arrCharacterToReplace = [".","$","[","]","¥",":",";",":","/","&","}","{","-","'","''","#"," "]
        for character in arrCharacterToReplace{
            
            if (titleStr.hasPrefix(character)) {
                titleStr = titleStr.replacingOccurrences(of: character, with: "")
            }
        }
        
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased()).child(newPostId)
                newHashTagRef.updateChildValues(["timestamp": timestamp])
            }
        }
        onSuccess()
    }
    
    
    
    static func updateDataToServer(tupleImages: [(image: UIImage, sort: Int)], ratios: [Dictionary<String, CGFloat>], imageCount: Int, title: String, caption: String, category1: String, category2: String, status: String, shipPayer: String, shipWay: String, shipDate: String, shipFrom: String, price: Int, brand: String?, postId: String, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        
        var thumbnailUrl: String?
        var thumbnailRatioDict: Dictionary<String, CGFloat>?
        var imageUrls = [String]()
        
        var imageUrl_0: String?
        var imageUrl_1: String?
        var imageUrl_2: String?
        var imageUrl_3: String?
        
        
        
        uploadThumbnail(thumbnail: tupleImages[0].image, onSuccess: { (thumbUrl, thumbRatioDict) in
            thumbnailUrl = thumbUrl
            thumbnailRatioDict = thumbRatioDict
            
            updateDatabaseToPosts(thumbnailUrl: thumbnailUrl, thumbnailRatioDict: thumbnailRatioDict, imageUrls: imageUrls, ratios: ratios, imagesCount: tupleImages.count, title: title, caption: caption, category1: category1, category2: category2, status: status, shipPayer: shipPayer, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFrom, price: price, brand: brand, postId: postId, onSuccess: onSuccess, onError: onError)
        }, onError: onError)
        
        
        var count = 0
        for tupleImage in tupleImages {
            uploadImage(tupleImage: tupleImage, onSuccess: { (tupleImageUrl) in
                
                switch tupleImageUrl.sort {
                case 0:
                    imageUrl_0 = tupleImageUrl.imageUrl
                case 1:
                    imageUrl_1 = tupleImageUrl.imageUrl
                case 2:
                    imageUrl_2 = tupleImageUrl.imageUrl
                case 3:
                    imageUrl_3 = tupleImageUrl.imageUrl
                default:
                    print("t")
                }
                
                count += 1
                
                if count == tupleImages.count {
                    
                    switch tupleImages.count {
                    case 1:
                        imageUrls.append(imageUrl_0!)
                    case 2:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                    case 3:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                        imageUrls.append(imageUrl_2!)
                    case 4:
                        imageUrls.append(imageUrl_0!)
                        imageUrls.append(imageUrl_1!)
                        imageUrls.append(imageUrl_2!)
                        imageUrls.append(imageUrl_3!)
                        
                    default:
                        print("t")
                    }
                }
                
                if tupleImages.count == imageUrls.count {
                    
                    updateDatabaseToPosts(thumbnailUrl: thumbnailUrl, thumbnailRatioDict: thumbnailRatioDict, imageUrls: imageUrls, ratios: ratios, imagesCount: tupleImages.count, title: title, caption: caption, category1: category1, category2: category2, status: status, shipPayer: shipPayer, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFrom, price: price, brand: brand, postId: postId, onSuccess: onSuccess, onError: onError)
                    
                }
            }, onError: onError)
        }

    }
    
    static func updateDatabaseToPosts(thumbnailUrl: String?, thumbnailRatioDict: Dictionary<String, CGFloat>?, imageUrls: [String], ratios: [Dictionary<String, CGFloat>], imagesCount: Int, title: String, caption: String,category1: String, category2: String, status: String, shipPayer: String, shipWay: String, shipDate: String, shipFrom: String, price: Int, brand: String?, postId: String, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        if thumbnailUrl != nil && imageUrls.count == imagesCount {
            
            let postReference = Api.Post.REF_POSTS.child(postId)
            let timestamp = Int(Date().timeIntervalSince1970)
            guard let currentUid = Api.User.CURRENT_USER?.uid else {
                onError()
                return
            }
            
            var thumbDict: Dictionary<String, CGFloat> = thumbnailRatioDict!
            let thumbDictWidth0 = thumbDict[Config.ratioWidthKey]
            let thumbDictHeight0 = thumbDict[Config.ratioHeightKey]
            
            switch (imagesCount - 1) {
            case 0:
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "ratio0": ratios[0],  "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                postReference.updateChildValues(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        
                        
                        updateMyPostsDatabase(currentUid: currentUid, postId: postId, title: title, caption: caption, imageCount: imagesCount, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
            case 1:
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "ratio0": ratios[0], "ratio1": ratios[1], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                postReference.updateChildValues(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        updateMyPostsDatabase(currentUid: currentUid, postId: postId, title: title, caption: caption, imageCount: imagesCount, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
            case 2:
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount, "image0": imageUrls[0], "image1": imageUrls[1], "image2": imageUrls[2], "ratio0": ratios[0], "ratio1": ratios[1], "ratio2": ratios[2], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                postReference.updateChildValues(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        updateMyPostsDatabase(currentUid: currentUid, postId: postId, title: title, caption: caption, imageCount: imagesCount, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
            case 3:
                let dict = ["thumbnail": thumbnailUrl, "thumbnailRatio": [Config.ratioWidthKey: thumbDictWidth0, Config.ratioHeightKey: thumbDictHeight0], "uid": currentUid, "title": title, "caption": caption, "timestamp": timestamp, "imageCount": imagesCount,"image0": imageUrls[0], "image1": imageUrls[1], "image2": imageUrls[2], "image3": imageUrls[3], "ratio0": ratios[0], "ratio1": ratios[1], "ratio2": ratios[2], "ratio3": ratios[3], "category1": category1, "category2": category2, "status": status, "shipPayer": shipPayer, "shipWay": shipWay, "shipDeadLine": shipDate, "shipFrom": shipFrom, "price": price, "brand": brand, "transactionStatus": Config.sell, Config.sellerShouldDo: Config.nowOnSell] as? [String : Any]
                postReference.updateChildValues(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error?.localizedDescription)
                        onError()
                        ProgressHUD.showError()
                    } else {
                        updateMyPostsDatabase(currentUid: currentUid, postId: postId, title: title, caption: caption, imageCount: imagesCount, timestamp: timestamp, onSuccess: onSuccess, onError: onError)
                    }
                })
                
                
            default:
                print("t")
            }
        }
    }
    static func updateMyPostsDatabase(currentUid: String, postId: String, title: String, caption: String, imageCount: Int, timestamp: Int, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        
        // postをアップデートしたあとに呼ばれる。
        // updaetChildValuesでpostの情報をアップデートしただけなので、画像が減っていても、削除されていない。
        // そこで下記のコードで余分な画像と比率ratioを削除する。 画像が1枚だけであれば、２枚目以降はすべて削除. 2枚あれば、3枚目以降削除。
        switch imageCount {
        case 1:
            Api.Post.REF_POSTS.child(postId).child("image1").removeValue()
            Api.Post.REF_POSTS.child(postId).child("image2").removeValue()
            Api.Post.REF_POSTS.child(postId).child("image3").removeValue()
            Api.Post.REF_POSTS.child(postId).child("ratio1").removeValue()
            Api.Post.REF_POSTS.child(postId).child("ratio2").removeValue()
            Api.Post.REF_POSTS.child(postId).child("ratio3").removeValue()
        case 2:
            Api.Post.REF_POSTS.child(postId).child("image2").removeValue()
            Api.Post.REF_POSTS.child(postId).child("image3").removeValue()
            Api.Post.REF_POSTS.child(postId).child("ratio2").removeValue()
            Api.Post.REF_POSTS.child(postId).child("ratio3").removeValue()
        case 3:
            Api.Post.REF_POSTS.child(postId).child("image3").removeValue()
            Api.Post.REF_POSTS.child(postId).child("ratio3").removeValue()
            
        default:
            print("t")
        }
        
        let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUid).child(postId)
        myPostRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                onError()
                return
            }
        })
        
        let mySellPostsRef = Api.MySellPosts.REF_MYSELL.child(currentUid).child(postId)
        mySellPostsRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                onError()
                return
            }
        })
        
        
        var titleStr = title
        let arrCharacterToReplace = [".","$","[","]","¥",":",";",":","/","&","}","{","-","'","''","#"," "]
        for character in arrCharacterToReplace{
            
            if (titleStr.hasPrefix(character)) {
                titleStr = titleStr.replacingOccurrences(of: character, with: "")
            }
        }
        
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased()).child(postId)
                newHashTagRef.updateChildValues(["timestamp": timestamp])
            }
        }
        onSuccess()
    }
}
