//
//  ProfileMenuViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/20.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import EMAlertController
import StoreKit
import IQKeyboardManagerSwift

class ProfileMenuViewController: UIViewController {
    
    @IBOutlet weak var userRegisterBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userRegisterBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var strs = ["プロフィール", "設定","出品した商品","下書きの商品","購入した商品","いいねした商品","コメントした商品","売上管理","アプリを応援する","お問い合わせ"]
    
    var icons: [UIImage] = [#imageLiteral(resourceName: "personImage"),#imageLiteral(resourceName: "setting"),#imageLiteral(resourceName: "hanger"),#imageLiteral(resourceName: "draft"),#imageLiteral(resourceName: "cart"),#imageLiteral(resourceName: "heartImage"),#imageLiteral(resourceName: "commentImage"),#imageLiteral(resourceName: "yen"),#imageLiteral(resourceName: "cheer"),#imageLiteral(resourceName: "questionblack")]
    
    var myNotificationExistFlg = false
    var myAllNotiCount = 0
    
    var currentUid = String()
    
    var badgeSellerFlg = false
    var badgePurchaseFlg = false
    
    var purchasePosts = [Post]()
    var sellPosts = [Post]()
    var firstCallPurchaseFlg = false
    var firstCallSellFlg = false
    var noAuthFlg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let _ = Api.User.CURRENT_USER?.uid {
            userRegisterBtnHeightConstraint.constant = 0
            userRegisterBtn.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    @IBAction func userRegister_TouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
    }
    
    
    
    
    func fetchDot() {
        
        self.purchasePosts.removeAll()
        self.sellPosts.removeAll()
        self.badgePurchaseFlg = false
        self.badgeSellerFlg = false
        if let tabBarItem = self.tabBarItem as? ESTabBarItem {
            tabBarItem.badgeValue = nil
        }
        Api.MyPurchasePosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in
            
            if let post = post {
                if post.purchaserShouldDo == Config.catchProduct {

                    self.badgePurchaseFlg = true
                    if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                        tabBarItem.badgeValue = ""
                    }
                }
                self.purchasePosts.append(post)
                self.collectionView.reloadData()
                self.fetchChangePurchaseDot()
            }
        }
        
        Api.MySellPosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in
            
            if let post = post {
                if post.sellerShouldDo == Config.ship || post.sellerShouldDo == Config.valueBuyer {
                    self.badgeSellerFlg = true
                    if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                        tabBarItem.badgeValue = ""
                    }
                }
                self.sellPosts.append(post)
                self.collectionView.reloadData()
                self.fetchChangeSellDot()
            }
        }
    }
    
    func fetchChangePurchaseDot() {
        
        if !firstCallPurchaseFlg {
            firstCallPurchaseFlg = true
            Api.MyPurchasePosts.observeChangeMyPurchase(userId: currentUid) { (post) in
                
                self.badgePurchaseFlg = false
                if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                    tabBarItem.badgeValue = nil
                }
                
                var count = 0
                for purchasePost in self.purchasePosts {
                    
                    if let post = post {
                        if post.id == purchasePost.id {
                            self.purchasePosts[count] = post
                        }
                    }
                    count += 1
                }
                
                for purchasePost in self.purchasePosts {
                    if purchasePost.purchaserShouldDo == Config.catchProduct && purchasePost.purchaserUid == self.currentUid {
                        self.badgePurchaseFlg = true
                        if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                            tabBarItem.badgeValue = ""
                        }
                        //       }
                    }
                }
                
                self.collectionView.reloadData()
            }
        }
        
        
    }
    
    func fetchChangeSellDot() {
        
        if !firstCallSellFlg {
            firstCallSellFlg = true
            Api.MySellPosts.observeChangeMySell(userId: currentUid) { (post) in
                
                self.badgeSellerFlg = false
                if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                    tabBarItem.badgeValue = nil
                }
                
                var count = 0
                for sellPost in self.sellPosts {
                    
                    if let post = post {
                        if post.id == sellPost.id {
                            self.sellPosts[count] = post
                        }
                    }
                    count += 1
                }
                
                for sellPost in self.sellPosts {
                    if sellPost.sellerShouldDo == Config.ship || sellPost.sellerShouldDo == Config.valueBuyer {
                        
                        //                if sellPost.uid == self.currentUid {
                        self.badgePurchaseFlg = true
                        if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                            tabBarItem.badgeValue = ""
                        }
                        //              }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            fetchDot()
            
        } else {
            print("noAuth")
            noAuthFlg = true
        }

    }
}


extension ProfileMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return strs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileMenuCollectionViewCell", for: indexPath) as! ProfileMenuCollectionViewCell
        
        cell.iconImageView.image = icons[indexPath.item]
        cell.stringLbl.text = strs[indexPath.item]
        cell.redDotImageView.isHidden = true
        
        if !noAuthFlg {
            
            
            if badgeSellerFlg {
                
                if cell.stringLbl.text == strs[2] {
                    cell.redDotImageView.isHidden = false
                }
            } else {
                if cell.stringLbl.text == strs[2] {
                    cell.redDotImageView.isHidden = true
                }
            }
            
            if badgePurchaseFlg {
                if cell.stringLbl.text == strs[4] {
                    cell.redDotImageView.isHidden = false
                }
            } else {
                if cell.stringLbl.text == strs[4] {
                    cell.redDotImageView.isHidden = true
                }
            }
            
            return cell
            
        }
            // noAuthの場合、
        else {
            
            if (0...7).contains(indexPath.item) {
                let tintAbleImage = cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.iconImageView.image = tintAbleImage
                cell.iconImageView.tintColor = UIColor.lightGray
                cell.stringLbl.textColor = UIColor.lightGray
            }
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ビュー遷移時にタブバーを隠して、戻ってきたらタブバーを再表示させる方法
        
        
        if !noAuthFlg {
            switch indexPath.item {
            case 0:
                if Config.isUnderIphoneSE {
                    self.performSegue(withIdentifier: "goToProfileSegue_iPhoneSE", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "goToProfileSegue", sender: nil)
                }
                break;
            case 1:
                self.performSegue(withIdentifier: "goToSettingSegue", sender: nil)
                break;
            case 2:
                self.performSegue(withIdentifier: "goToSellSegue", sender: nil)
                break;
            case 3:
                self.performSegue(withIdentifier: "DraftPost_Seg", sender: nil)
                break;
            case 4:
                self.performSegue(withIdentifier: "goToPurchaseSegue", sender: nil)
                break;
            case 5:
                self.performSegue(withIdentifier: "goToMyLike_Seg", sender: nil)
                break;
            case 6:
                self.performSegue(withIdentifier: "goToMyComment_Seg", sender: nil)
                break;
            case 7:
                self.performSegue(withIdentifier: "goToSalesManagement", sender: nil)
                break;
                
                
            default:
                print("t")
            }
        }
        
        if indexPath.item == 8 {
            self.evaluateAppAlert()
        } else if indexPath.item == 9 {
            self.performSegue(withIdentifier: "goToHelpSegue", sender: nil)
            
        }
    }
    
    @objc func applicationDidBecomeActive() {
        
        //いいね、購入時の良い評価、売却時の良い評価どれか一つでもつけるたびに（Config.count_forEvaluateApp）+=1。
        //カウントが過ぎれば、次アプリを起動した時に、アプリのレビューに誘導する。 誘導したらカウントを消去。
        //すでにアプリを評価したら二度とアラートを出さない。 （Config.count_forEvaluateApp）-= 1
        //一度この誘導アラートを出したら、Config.guideToReviewAlert = 1
        //二度この誘導アラートを出したら、Config.guideToReviewAlert = 2
        //三度目がラストで、Config.guideToReviewAlert == 2 && Config.count_forEvaluateApp == 20
        //になったときに、最後はアラートを出さずに簡略版のアプリ評価を出現させる。これで誘導は最後になるので、
        //Config.count_forEvaluateApp）-= 1 とする。
        //（機種変用）Userノードに"isAppReview"があれば、すでに評価済みのアカウントなので、アラートを表示させないようにする。
        
        let userDefaults = UserDefaults.standard
        var guideToReviewAlert = userDefaults.integer(forKey: Config.guideToReviewAlert)
        var count_forEvaluate = userDefaults.integer(forKey: Config.count_forEvaluateApp)
        
        //すでに評価済み
        if guideToReviewAlert == -1 {
            return;
        }
        
       
        
        if (guideToReviewAlert == 0 && count_forEvaluate >= 1)
         || (guideToReviewAlert == 1 && count_forEvaluate >= 10) {
            //初期化  また一から評価をためていく。
            userDefaults.removeObject(forKey: Config.count_forEvaluateApp)
            
            if let currentUid = Api.User.CURRENT_USER?.uid {
                Api.User.observeUser(withId: currentUid) { (usermodel) in
                    //アプリをすでにレビュー済みかどうか確認。レビュー済みなら、-1の値をuserDefaultsに入れる。
                    if let _ = usermodel?.isAppReview {
                        userDefaults.set(-1, forKey: Config.guideToReviewAlert)
                        return;
                    } else {
                        self.showGoodThumbAlert(guideToReviewAlert: guideToReviewAlert)
                    }
                }
            } else {
                 self.showGoodThumbAlert(guideToReviewAlert: guideToReviewAlert)
            }
        }
        
        //３回目の評価誘導　これで最後なので、もうアラートは出さないようにする。
        if (guideToReviewAlert == 2 && count_forEvaluate >= 20) {
            userDefaults.set(-1, forKey: Config.guideToReviewAlert)
            if let currentUid = Api.User.CURRENT_USER?.uid {
                Api.User.REF_USERS.child(currentUid).updateChildValues(["isAppReview": true])
            }
            self.appReviewEasyType()
        }
    }
    
    func showGoodThumbAlert(guideToReviewAlert: Int) {
        let userDefaults = UserDefaults.standard
        let alert = EMAlertController(icon: UIImage(named: "goodthumb"), title: "", message: "アプリを気に入っていただけましたか？")
        
        let action1 = EMAlertAction(title: "いいえ", style: .normal) {
            if guideToReviewAlert == 0 {
                userDefaults.set(1, forKey: Config.guideToReviewAlert)
            }
            
            if guideToReviewAlert == 1 {
                userDefaults.set(2, forKey: Config.guideToReviewAlert)
            }
        }
        let action2 = EMAlertAction(title: "はい", style: .cancel) {
            if guideToReviewAlert == 0 {
                userDefaults.set(1, forKey: Config.guideToReviewAlert)
            }
            
            if guideToReviewAlert == 1 {
                userDefaults.set(2, forKey: Config.guideToReviewAlert)
            }
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
                print(Thread.isMainThread)
                self.evaluateAppAlert()
            })
            
        }
        
        action1.titleColor = .black
        action2.titleColor = .blue
        alert.addAction(action: action1)
        alert.addAction(action: action2)
        
        present(alert, animated: true, completion: nil)
    }
    
    func evaluateAppAlert() {
        let alert = EMAlertController(icon: UIImage(named: "ozigi"), title: "運営者の中西と申します。これからもアプリの改善を行っていきます！", message: "もしよろしければレビューをしてアプリを応援してくれませんか？")
        
        let action1 = EMAlertAction(title: "いいえ", style: .normal) {
            
        }
        let action2 = EMAlertAction(title: "レビューする", style: .cancel) {
            UserDefaults.standard.set(-1, forKey: Config.guideToReviewAlert)
            if let currentUid = Api.User.CURRENT_USER?.uid {
                Api.User.REF_USERS.child(currentUid).updateChildValues(["isAppReview": true])
            }
            
            self.appReview()
        }
        
        action1.titleColor = .black
        action2.titleColor = .blue
        alert.addAction(action: action1)
        alert.addAction(action: action2)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func appReview() {
        
        //ここ変更する アプリURL
        if let url = URL(string: Config.appReviewUrl) {
            UIApplication.shared.open(url)
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func appReviewEasyType() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}

extension ProfileMenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}
