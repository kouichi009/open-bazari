//
//  NotificationViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import BadgeSegmentControl
import FirebaseDatabase
import BadgeSwift
import ESTabBarController_swift
import IQKeyboardManagerSwift

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: BadgeSegmentControl!
    
    
    var myNotifications = [Notification]()
    var transactionNotifications = [Notification]()
    var selectedNotifications = [Notification]()
    var myNotificationPosts = [Post]()
    var transactionNotificationPosts = [Post]()
    var selectedPosts = [Post]()
    
    var currentUid = String()
    
    var pageForTable = 0
    var increaseNumForTable = 0
    var pullFlg = false
    var underPagePostFlg = false
    var neverCallFlg = false
    
    let refreshControl = UIRefreshControl()
    
    let firstSegmentName = "あなた宛"
    let secondSegmentName = "取引"
    
    var segmentIndex = 0
    
    
    var myNotificationExistFlg = false
    
    var myAllNotiCount = 0
    
    var usermodels = [UserModel]()
    
    var noMoreFlg = false
    var badgeYouCount = 0
    var badgeTransactionCount = 0
    var tapFlg = false
    var dot = UIView()
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        HelperService.notiVC = self
        
        setSegmentControl()
        
        self.pageForTable = Config.pageForTable
        self.increaseNumForTable = Config.increaseNumForTable
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
            //いいねしてた商品が値下げされたら呼ばれる
            Api.Notification.observeChangeMyNotification(uid: currentUid) { (notification) in
                
                if notification.type == "priceDown" {
                    Api.Post.observePost(postId: notification.objectId!, completion: { (post) in
                        
                        if let post = post {
                            var myNotiCount = 0
                            var selectNotiCount = 0
                            for myNotiPost in self.myNotificationPosts {
                                
                                if myNotiPost.id == notification.objectId {
                                    self.myNotificationPosts[myNotiCount] = post
                                }
                                myNotiCount += 1
                            }
                            
                            for selectPost in self.selectedPosts {
                                
                                if selectPost.id == notification.objectId {
                                    self.selectedPosts[selectNotiCount] = post
                                    self.tableView.reloadData()
                                }
                                selectNotiCount += 1
                                
                            }
                        }
                    })
                }
            }
            
            
            Api.User.observeAllUsers { (usermodel, userCount) in
                
                if let usermodel = usermodel {
                    self.usermodels.append(usermodel)
                }
            }
            
            Api.Notification.fetchNotificationCount(uid: currentUid) { (myNotiCount) in
                
                self.myAllNotiCount = myNotiCount
                print("myCount \(myNotiCount)")
                if myNotiCount == 0 {
                    self.myNotificationExistFlg = false
                } else {
                    self.myNotificationExistFlg = true
                    self.loadFirstNotifications()
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        badgeInitialize()
    }
    
    
    
    func initialize() {
        
        //初期化
        noMoreFlg = false
        pageForTable = Config.pageForTable
        increaseNumForTable = Config.increaseNumForTable
        badgeInitialize()
        self.selectedNotifications.removeAll()
        self.selectedPosts.removeAll()
        self.tableView.reloadData()
        
        
    }
    
    func loadFirstNotifications() {
        
        if myNotificationExistFlg == false {
            return
        }
        
        var count = 0
        Api.Notification.observeNotificationAdd(uid: currentUid) { (notification) in
            
            print(notification.from)
            print(notification.id)
            print(notification.type)
            
            
            Api.Post.observePost(postId: notification.objectId!, completion: { (post) in
                
                
                
                //     if post == nil {
                print(notification.objectId)
                print(notification.from)
                print(notification.type)
                print(post)
                //}
                
                count += 1
                
                if let post = post {
                    
                    
                    if notification.segmentType == Config.you {
                        self.myNotifications.insert(notification, at: 0)
                        self.myNotificationPosts.insert(post, at: 0)
                        
                        if notification.checked == false {
                            self.badgeYouCount += 1
                            self.segmentControl.updateBadge(forValue: self.badgeYouCount, andSection: 0)
                        }
                    }
                    
                    if notification.segmentType == Config.transaction {
                        self.transactionNotifications.insert(notification, at: 0)
                        self.transactionNotificationPosts.insert(post, at: 0)
                        
                        if notification.checked == false {
                            self.badgeTransactionCount += 1
                            self.segmentControl.updateBadge(forValue: self.badgeTransactionCount, andSection: 1)
                        }
                    }
                }
                    // followと運営からのお知らせ
                else {
                    
                    self.myNotificationPosts.insert(Post(), at: 0)
                    
                    if notification.checked == false {
                        self.badgeYouCount += 1
                        self.segmentControl.updateBadge(forValue: self.badgeYouCount, andSection: 0)
                    }
                    
                    if notification.from == "admin" {
                        self.myNotifications.insert(notification, at: 0)
                        
                    } else if (notification.id?.contains(self.currentUid))! {
                        self.myNotifications.insert(notification, at: 0)
                    }
                }
                
                if self.neverCallFlg == true {
                    
                    if let tabBarItem = self.tabBarItem as? ESTabBarItem {
                        
                        tabBarItem.badgeValue = ""
                        
                        
                        if self.tabBarController?.selectedIndex == 3 {
                            tabBarItem.badgeValue = nil
                        }
                    }
                    
                    if self.segmentIndex == 0 {
                        if notification.segmentType == Config.you {
                            self.selectedNotifications.insert(notification, at: 0)
                            if let post = post {
                                self.selectedPosts.insert(post, at: 0)
                            } else {
                                self.selectedPosts.insert(Post(), at: 0)
                            }
                        }
                    } else {
                        if notification.segmentType == Config.transaction {
                            self.selectedNotifications.insert(notification, at: 0)
                            if let post = post {
                                self.selectedPosts.insert(post, at: 0)
                            } else {
                                self.selectedPosts.insert(Post(), at: 0)
                            }
                        }
                    }
                    
                    
                    if notification.from != "admin" {
                        
                        var isAlreadyExistUserModel = false
                        for usermodel in self.usermodels {
                            if usermodel.id == notification.from {
                                isAlreadyExistUserModel = true
                                break;
                            }
                        }
                        
                        if isAlreadyExistUserModel == false {
                            Api.User.observeUser(withId: notification.from!, completion: { (usermodel) in
                                
                                if let usermodel = usermodel {
                                    self.usermodels.append(usermodel)
                                    
                                    self.tableView.reloadData()
                                    return;
                                }
                            })
                        }
                        
                        if isAlreadyExistUserModel {
                            self.tableView.reloadData()
                            return;
                        }
                    } else {
                        self.tableView.reloadData()
                        return;
                    }
                    
                }
                
                if count == self.myAllNotiCount {
                    
                    print(count)
                    print(self.myAllNotiCount)
                    self.neverCallFlg = true
                    if self.segmentIndex == 0 {
                        self.selectedNotifications = self.myNotifications.prefix(self.pageForTable).map {$0}
                        self.selectedPosts = self.myNotificationPosts.prefix(self.pageForTable).map {$0}
                    } else {
                        self.selectedNotifications = self.transactionNotifications.prefix(self.pageForTable).map {$0}
                        self.selectedPosts = self.transactionNotificationPosts.prefix(self.pageForTable).map {$0}
                    }
                    
                    self.badgeInitialize()
                    self.tableView.reloadData()
                }
                //////////////////
            })
            
        }
        
    }
    
    func badgeInitialize() {
        
        
        if let tabBarItem = self.tabBarItem as? ESTabBarItem {
            
            tabBarItem.badgeValue = nil
        }
        
        let currentSelectIndex = self.segmentControl.selectedSegmentIndex
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            if currentSelectIndex == 0 {
                self.badgeYouCount = 0
                self.segmentControl.updateBadge(forValue: 0, andSection: 0)
                
                self.myNotifications.forEach({ (notification) in
                    
                    print("notificationCheckdedPP ", notification.checked)
                    if !notification.checked! {
                        Api.Notification.REF_NOTIFICATION.child(notification.id!).updateChildValues(["checked": true])
                        notification.checked = true
                    }
                    print("notificationCheckdedPP02 ", notification.checked)
                    
                })
            } else {
                self.badgeTransactionCount = 0
                self.segmentControl.updateBadge(forValue: 0, andSection: 1)
                self.transactionNotifications.forEach({ (notification) in
                    if !notification.checked! {
                        Api.Notification.REF_NOTIFICATION.child(notification.id!).updateChildValues(["checked": true])
                        notification.checked = true
                    }
                })
            }
        }
    }
    
    func loadNotifications() {
        
        initialize()
        
        print("mynotiCount \(self.myNotifications.count)")
        print("self.transactionNotificationsCount \(self.transactionNotifications.count)")
        if segmentIndex == 0 {
            self.selectedNotifications = self.myNotifications.prefix(self.pageForTable).map {$0}
            self.selectedPosts = self.myNotificationPosts.prefix(self.pageForTable).map {$0}
            
        } else {
            self.selectedNotifications = self.transactionNotifications.prefix(self.pageForTable).map {$0}
            self.selectedPosts = self.transactionNotificationPosts.prefix(self.pageForTable).map {$0}
            
        }
        self.tableView.reloadData()
    }
    
    
    func setSegmentControl() {
        
        self.segmentControl.segmentAppearance = SegmentControlAppearance.appearance()
        
        // Add segments
        self.segmentControl.addSegmentWithTitle(self.firstSegmentName)
        self.segmentControl.addSegmentWithTitle(self.secondSegmentName)
        
        // Set segment with index 0 as selected by default
        self.segmentControl.selectedSegmentIndex = 0
        
        self.segmentControl.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)),
                                      for: .valueChanged)
        
    }
    
    // Segment selector for .ValueChanged
    @objc func selectSegmentInSegmentView(segmentView: BadgeSegmentControl) {
        print("Select segment at index: \(segmentView.selectedSegmentIndex)")
        
        segmentIndex = segmentView.selectedSegmentIndex
        
        self.loadNotifications()
    }
    
    @objc func refresh() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        myNotifications.forEach { (mynoti) in
            print(mynoti.from)
            print(myNotifications.count)
        }
        
        selectedNotifications.forEach { (seleNo) in
            print(seleNo.from)
            print(selectedNotifications.count)
        }
        
        self.tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if selectedNotifications.count < Config.pageForTable {
            return;
        }
        
        if noMoreFlg {
            return;
        }
        
        print("self.selectedNotifications.count \(self.selectedNotifications.count)")
        print("self.pageForTable \(self.pageForTable)")
        //        if self.selectedNotifications.count < self.pageForTable  {
        //            return;
        //        }
        
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        //pullRation 0.1 - 1.0
        if pullRatio >= 0.1 && !pullFlg {
            self.pullFlg = true
            self.loadMorePosts()
        }
        
        if pullRatio == 0.0 {
            self.pullFlg = false
            
        }
        print("pullRation:\(pullRatio)")
    }
    
    
    
    func loadMorePosts() {
        
        //prePage
        var prepage = pageForTable
        
        
        // increase page size
        pageForTable = pageForTable + increaseNumForTable
        
        print("prepage \(prepage)")
        print("selectedNotifications.count \(selectedNotifications.count)")
        print("self.pageForTable \(self.pageForTable)")
        print(selectedPosts.count)
        print(selectedNotifications.count)
        print(pageForTable)
        
        if prepage > selectedNotifications.count {
            
            prepage = selectedNotifications.count
            pageForTable = selectedNotifications.count
            
            switch self.segmentIndex {
                
            case 0:
                
                self.selectedNotifications = myNotifications
                self.selectedPosts = self.myNotificationPosts
                
            case 1:
                self.selectedNotifications = transactionNotifications
                self.selectedPosts = self.transactionNotificationPosts
                
            default:
                print("t")
                
            }
            
            self.tableView.reloadData()
            ProgressHUD.showSuccess("ロード完了")
            noMoreFlg = true
            
            print(selectedPosts.count)
            print(selectedNotifications.count)
            print(pageForTable)
            return;
        }
        
        SVProgressHUD.show()
        
        switch self.segmentIndex {
            
        case 0:
            
            self.selectedNotifications = self.myNotifications.prefix(self.pageForTable).map {$0}
            self.selectedPosts = self.myNotificationPosts.prefix(self.pageForTable).map {$0}
            
            
        case 1:
            self.selectedNotifications = self.transactionNotifications.prefix(self.pageForTable).map {$0}
            self.selectedPosts = self.transactionNotificationPosts.prefix(self.pageForTable).map {$0}
            
        default:
            print("t")
            
        }
        
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailSegue" {
            
            let detailVC = segue.destination as! DetailViewController
            let postId  = sender as! String
            detailVC.postId = postId
        }
        
        if segue.identifier == "goToProfileUserSeg" || segue.identifier == "goToProfileUserSeg_iPhoneSE"  {

            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserVC.userId = userId
        }
        
        if segue.identifier == "sellTransactionNavi1_Seg" {
            
            let sellNaviVC = segue.destination as! SellNavi1ViewController
            let post  = sender as? Post
            sellNaviVC.post = post
        }
        
        if segue.identifier == "sellTransactionNavi2_Seg" {
            
            let sellNaviVC = segue.destination as! SellNavi2ViewController
            let post  = sender as? Post
            sellNaviVC.post = post
        }
        
        if segue.identifier == "purchaseTransactionNavi1_Seg" {
            
            let purchaseNaviVC = segue.destination as! PurchaseNavi1ViewController
            let post  = sender as? Post
            purchaseNaviVC.post = post
        }
        
        if segue.identifier == "purchaseTransactionNavi2_Seg" {
            
            let purchaseNaviVC = segue.destination as! PurchaseNavi2ViewController
            let post  = sender as? Post
            purchaseNaviVC.post = post
        }
        if segue.identifier == "sellTransactionNavi3_Seg" {
            
            let sellNaviVC = segue.destination as! SellNavi3ViewController
            let post  = sender as? Post
            sellNaviVC.post = post
        }
        
        if segue.identifier == "purchaseTransactionNavi4_Seg" {
            
            let purchaseNaviVC = segue.destination as! PurchaseNavi4ViewController
            let post  = sender as? Post
            purchaseNaviVC.post = post
        }
        
        if segue.identifier == "sellTransactionNavi4_Seg" {
            
            let sellNaviVC = segue.destination as! SellNavi4ViewController
            let post  = sender as? Post
            sellNaviVC.post = post
        }
        
        if segue.identifier == "purchaseTransactionNavi3_Seg" {
            
            let purchaseNaviVC = segue.destination as! PurchaseNavi3ViewController
            let post  = sender as? Post
            purchaseNaviVC.post = post
        }
        
        
        
    }
    
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        
        let selectNotification = self.selectedNotifications[indexPath.row]
        for usermodel in usermodels {
            if usermodel.id == selectNotification.from {
                cell.usermodel = usermodel
            }
        }
        
        cell.post = self.selectedPosts[indexPath.row]
        cell.notification = selectNotification
        
        print(selectedNotifications.count)
        print("type ", selectNotification.type)
        print(selectedPosts.count)
        print(indexPath.row)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedPost = selectedPosts[indexPath.row]
        let selectedNoti = selectedNotifications[indexPath.row]
        
        print(selectedNoti.type)
        print(selectedPost.sellerShouldDo)
        print(selectedPost.purchaserShouldDo)
        print(selectedNoti.type)
        print(selectedPost.sellerShouldDo)
        
        
        
        if segmentIndex == 0 {
            
            if selectedNotifications[indexPath.row].type == "follow" {
                
                if Config.isUnderIphoneSE {
                    performSegue(withIdentifier: "goToProfileUserSeg_iPhoneSE", sender: selectedNotifications[indexPath.row].from)
                    
                } else {
                    performSegue(withIdentifier: "goToProfileUserSeg", sender: selectedNotifications[indexPath.row].from)
                }
                
            } else if selectedNotifications[indexPath.row].type == "comment" || selectedNotifications[indexPath.row].type == "like" || selectedNotifications[indexPath.row].type == "priceDown" {
                self.performSegue(withIdentifier: "DetailSegue", sender: selectedNotifications[indexPath.row].objectId)
            }
            return;
        }
        
        if !tapFlg {
            tapFlg = true
            SVProgressHUD.show()
            Api.Post.observePost(postId: selectedNotifications[indexPath.row].objectId!) { (post) in
                self.tapFlg = false
                SVProgressHUD.dismiss()
                print("post.id ", post?.id)
                
                if let post = post {
                    
                    
                    print(post.uid)
                    print(post.sellerShouldDo)
                    print(post.purchaserShouldDo)
                    print(selectedNoti.to)
                    print(selectedNoti.type)
                    
                    
                    if post.sellerShouldDo == Config.ship && selectedNoti.type == Config.naviPurchase && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "sellTransactionNavi1_Seg", sender: post)
                        
                    }
                    else if post.sellerShouldDo == Config.waitCatch && selectedNoti.type == Config.naviPurchase && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "sellTransactionNavi2_Seg", sender: post)
                        
                    }
                        
                        
                        
                    else if post.purchaserShouldDo == Config.catchProduct && selectedNoti.type == Config.naviShip && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi2_Seg", sender: post)
                        
                    }
                        
                    else if post.purchaserShouldDo == Config.waitForValue && selectedNoti.type == Config.naviShip && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi3_Seg", sender: post)
                        
                    }
                        
                    else if post.sellerShouldDo == Config.valueBuyer && selectedNoti.type == Config.naviEvaluatePurchaser && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "sellTransactionNavi3_Seg", sender: post)
                        
                    }
                        
                    else if post.sellerShouldDo == Config.valueBuyer && selectedNoti.type == Config.naviPurchase && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "sellTransactionNavi3_Seg", sender: post)
                        
                    }
                        
                        
                    else if post.purchaserShouldDo == Config.buyFinish && selectedNoti.type == Config.naviEvaluateSeller && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi4_Seg", sender: post)
                        
                    }
                        
                    else if post.purchaserShouldDo == Config.buyFinish && selectedNoti.type == Config.naviShip && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi4_Seg", sender: post)
                        
                    }
                        
                    else if post.sellerShouldDo == Config.soldFinish && selectedNoti.type == Config.naviEvaluatePurchaser && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "sellTransactionNavi4_Seg", sender: post)
                        
                    }
                        
                    else if post.sellerShouldDo == Config.soldFinish && selectedNoti.type == Config.naviPurchase && self.segmentIndex == 1 {
                        self.performSegue(withIdentifier: "sellTransactionNavi4_Seg", sender: post)
                        
                    }
                    
                    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    
                    
                    else if post.sellerShouldDo == Config.ship && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid == selectedNoti.to {
                        self.performSegue(withIdentifier: "sellTransactionNavi1_Seg", sender: post)
                        
                    }
                    else if post.sellerShouldDo == Config.waitCatch && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid == selectedNoti.to {
                        self.performSegue(withIdentifier: "sellTransactionNavi2_Seg", sender: post)
                        
                    }
                        
                    else if post.sellerShouldDo == Config.valueBuyer && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid == selectedNoti.to {
                        self.performSegue(withIdentifier: "sellTransactionNavi3_Seg", sender: post)
                        
                    }
                        
                    else if post.sellerShouldDo == Config.soldFinish && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid == selectedNoti.to {
                        self.performSegue(withIdentifier: "sellTransactionNavi4_Seg", sender: post)
                        
                    }
                        
                        /////////////////////////////////////////////////////////////////
                        
                    else if post.purchaserShouldDo == Config.waitForShip && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid != selectedNoti.to {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi1_Seg", sender: post)
                        
                    }
                        
                    else if post.purchaserShouldDo == Config.catchProduct && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid != selectedNoti.to {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi2_Seg", sender: post)
                        
                    }
                        
                    else if post.purchaserShouldDo == Config.waitForValue && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid != selectedNoti.to {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi3_Seg", sender: post)
                        
                    }
                        
                        
                    else if post.purchaserShouldDo == Config.buyFinish && selectedNoti.type == Config.naviMessage && self.segmentIndex == 1 && post.uid != selectedNoti.to {
                        self.performSegue(withIdentifier: "purchaseTransactionNavi4_Seg", sender: post)
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    
}

extension NotificationViewController: ReloadNotificationDelegate {
    func reloadNotification() {
        print("relaaddd")
        
        //      loadNotifications()
    }
}
