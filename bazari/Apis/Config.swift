//
//  Config.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
struct Config {
    
    static var STORAGE_ROOF_REF = ""
    static let BLOCK_USERS = "blockUsers"
    static var AnonymousImageURL = ""
    static var adminImage = ""
    static var page = 24
    static var increaseNum = 24
    static var pageForTable = 12
    static var increaseNumForTable = 12
    static var isUnderIphoneSE = false
    static var LoginTypeStr = "loginType"
    static var LoginTypeEmail = "Email"
    static var LoginTypeGoogle = "Google"
    static var LoginTypeTwitter = "Twitter"
    static var LoginTypeFacebook = "Facebook"
    static var LoginTypeAnonymous = "Anonymous"
    static var LoginTypeLINE = "LINE"
    static var selfIntroStr = "SELF_INTRODUCTION"
    static var sell = "sell"
    static let CAMERA = "カメラ"
    static var transaction = "transaction"
    static var discount = "discount"
    static var you = "you"
    static var sold = "sold"
    static var sun = "sun"
    static var cloud = "cloud"
    static var rain = "rain"
    static var CATEGORY1 = "category1"
    static var CATEGORY2 = "category2"
    static var BRAND = "brand"
    static var purchaserShouldDo = "purchaserShouldDo"
    static var yen = "¥"
    static var sellerShouldDo = "sellerShouldDo"
    static var naviPurchase = "naviPurchase"
    static var naviShip = "naviShip"
    static var naviEvaluateSeller = "naviEvaluateSeller"
    static var naviEvaluatePurchaser = "naviEvaluatePurchaser"
    static var naviMessage = "naviMessage"
    static var pushNotiTitleCount = 30
    static var count_forEvaluateApp = "count_forEvaluateApp"
    static var guideToReviewAlert = "guideToReviewAlert"
    static var shipDatesList = ["支払い後、1〜2日で発送","支払い後、2〜3日で発送","支払い後、4〜7日で発送"]
    static var mailToUrl = ""
    static var appReviewUrl = ""
    static var appName = "バザリ"
  
    static var shipPayerList = ["送料込み (あなたが負担)","着払い (購入者が負担)"]
 
    static let categories = ["デジタルカメラ", "フィルムカメラ","レンズ (オートフォーカス)","レンズ (マニュアルフォーカス)", "ミラーレス一眼","コンパクトデジタルカメラ","ビデオカメラ","ケース/バッグ","ストロボ/照明","フィルター","防湿庫","露出計","暗室関連用品","その他"]
    
    static let productStatuses = ["新品・未使用","AA (新品同様)","A (美品)","AB (良品)","B (並品)","C (やや難あり)", "J (故障品・ジャンク品)"]
    static let productSubtitles = ["新品のもの","外観に使用した形跡が無い。非常にきれいで、新品同様のもの", "外観に使用した形跡が少ない。きれいで、正常作動するもの", "外観に多少のキズや擦れなどがある。正常作動するもの", "外観に比較的目立つキズや擦れがある。テカリなどがあるが、正常作動するもの", "外観に目立つキズや擦れが多い。テカリなどがあるが、作動するもの", "作動に問題のあるもの。部品取り、コレクション用に。破損品。"]
    
    // firebase のクラウドメッセージタブのサーバーキーのトークン
    static var firebaseServerKey = ""
    
    
    static var herokuForStripeServerUrl = ""

    
       static var StripeApiKey = ""
//   // store stripe secret key // サーバー側のキー
       static var StripeSecretKeyForServer = ""
    
  
    // 3%
    static var commisionRate: Double = 0.03
    static var minimumPrice = 300
    static var maximumPrice = 200000
    static var minimumTransferApplyPrice = 1000
    static var maximumTransferApplyPrice = 500000
    
    static var application = "application"
    
    static let ratioWidthKey = "ratioWidthKey"
    static let ratioHeightKey = "ratioHeightKey"
    
    // 売った側
    static var nowOnSell = "出品中"
    static var ship = "商品の発送"
    static var waitCatch = "受取確認待ち"
    static var valueBuyer = "購入者の評価"
    static var soldFinish = "売却済"
    // 売った側
    
    
    // 買った側
    static var waitForShip = "商品発送待ち"
    static var catchProduct = "商品の受取"
    static var waitForValue = "相手の評価待ち"
    static var buyFinish = "購入済"
    // 買った側
    
    static var visa = "visa"
    static var mastercard = "mastercard"
}




extension Int {
    
    var seconds: Int {
        return self
    }
    
    var minutes: Int {
        return self.seconds * 60
    }
    
    var hours: Int {
        return self.minutes * 60
    }
    
    var days: Int {
        return self.hours * 24
    }
    
    var weeks: Int {
        return self.days * 7
    }
    
    var months: Int {
        return self.weeks * 4
    }
    
    var years: Int {
        return self.months * 12
    }
}
