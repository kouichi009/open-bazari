//
//  PurchaseTransactionViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/26.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import BadgeSegmentControl


class PurchaseTransactionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentControl: BadgeSegmentControl!
    
    var transactionPosts = [Post]()
    var soldPosts = [Post]()
    var selectedPosts = [Post]()
    
    var currentUid = String()
    
    var pageForTable = 0
    var increaseNumForTable = 0
    var pullFlg = false
    //    var reloadAllPostFlg = false
    var neverCallPostAddedFlg = false
    
    let refreshControl = UIRefreshControl()
    
    let firstSegmentName = "取引中"
    let secondSegmentName = "購入済"
    
    var segmentIndex = Int()
    
    var myPostExistFlg = false
    
    var noMoreFlg = false
    var badgeCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSegmentControl()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
        }
        
        self.title = "購入した商品"
        Api.MyPurchasePosts.fetchCountMyPurchasePosts(userId: currentUid) { (myPostCount) in
            
            if myPostCount == 0 {
                self.myPostExistFlg = false
            } else {
                self.myPostExistFlg = true
                self.loadAllPosts()
            }
        }
    }
    
    func initialize() {
        
        //初期化
        noMoreFlg = false
        pageForTable = Config.pageForTable
        increaseNumForTable = Config.increaseNumForTable
        self.badgeCount = 0
        self.segmentControl.updateBadge(forValue: 0, andSection: 0)
        self.selectedPosts.removeAll()
        self.transactionPosts.removeAll()
        self.soldPosts.removeAll()
        self.tableView.reloadData()
        
        
    }
    
    func loadAllPosts() {
        
        if myPostExistFlg == false {
            return
        }
        
        initialize()
        
        var count = 0
        
        Api.MyPurchasePosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in
            
            count += 1
            
            if let post = post {
                switch post.transactionStatus {
                    
                case Config.transaction:
                    self.transactionPosts.append(post)
                    if post.purchaserShouldDo == Config.catchProduct {
                        self.badgeCount += 1
                        self.segmentControl.updateBadge(forValue: self.badgeCount, andSection: 0)
                    }
                    break;
                case Config.sold:
                    self.soldPosts.append(post)
                    break;
                default:
                    print("t")
                    break;
                }
            }
            
            if postCount == count {
                
                
                switch self.segmentIndex {
                    
                case 0:
                    
                    self.selectedPosts = self.transactionPosts.prefix(self.pageForTable).map {$0}
                    
                case 1:
                    
                    self.selectedPosts = self.soldPosts.prefix(self.pageForTable).map {$0}
                    
                default:
                    print("t")
                    
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    func setSegmentControl() {
        
        self.segmentControl.segmentAppearance = SegmentControlAppearance.appearance()
        
        // Add segments
        self.segmentControl.addSegmentWithTitle(self.firstSegmentName)
        self.segmentControl.addSegmentWithTitle(self.secondSegmentName)
        
        self.segmentControl.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)),
                                      for: .valueChanged)
        
        // Set segment with index 0 as selected by default
        self.segmentControl.selectedSegmentIndex = 0
    }
    
    // Segment selector for .ValueChanged
    @objc func selectSegmentInSegmentView(segmentView: BadgeSegmentControl) {
        print("Select segment at index: \(segmentView.selectedSegmentIndex)")
        
        segmentIndex = segmentView.selectedSegmentIndex
        
        loadAllPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        self.loadAllPosts()
    }
    
    
    
    @objc func refresh() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        
        loadAllPosts()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("selectPosts ", selectedPosts.count)
        print(Config.pageForTable)
        if self.selectedPosts.count < self.pageForTable  {
            return;
        }
        
        if noMoreFlg {
            return;
        }
        
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
        //    print("pullRation:\(pullRatio)")
    }
    
    
    
    func loadMorePosts() {
        
        //prePage
        var prepage = pageForTable
        
        // increase page size
        pageForTable = pageForTable + increaseNumForTable
        
        if prepage >= selectedPosts.count {
            pageForTable = selectedPosts.count
            
            switch self.segmentIndex {
                
            case 0:
                
                self.selectedPosts = self.transactionPosts
                
            case 1:
                self.selectedPosts = self.soldPosts
                
            default:
                print("t")
                
            }
            
            self.tableView.reloadData()
            noMoreFlg = true
            
            print(selectedPosts.count)
            print(pageForTable)
            return;
        }
        
        
        
        SVProgressHUD.show()
        
        switch self.segmentIndex {
            
        case 0:
            
            self.selectedPosts = self.transactionPosts.prefix(self.pageForTable).map {$0}
            
        case 1:
            
            self.selectedPosts = self.soldPosts.prefix(self.pageForTable).map {$0}
            
        default:
            print("t")
            
        }
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        
        if segue.identifier == "purchaseTransactionNavi3_Seg" {
            
            let purchaseNaviVC = segue.destination as! PurchaseNavi3ViewController
            let post  = sender as? Post
            purchaseNaviVC.post = post
        }
        
        if segue.identifier == "purchaseTransactionNavi4_Seg" {
            
            let purchaseNaviVC = segue.destination as! PurchaseNavi4ViewController
            let post  = sender as? Post
            purchaseNaviVC.post = post
        }
    }
    
}

extension PurchaseTransactionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseListTableViewCell", for: indexPath) as! PurchaseListTableViewCell
        
        let post = selectedPosts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if selectedPosts[indexPath.row].purchaserShouldDo == Config.waitForShip && segmentIndex == 0 {
            self.performSegue(withIdentifier: "purchaseTransactionNavi1_Seg", sender: selectedPosts[indexPath.item])
            
        } else if selectedPosts[indexPath.row].purchaserShouldDo == Config.catchProduct && segmentIndex == 0 {
            self.performSegue(withIdentifier: "purchaseTransactionNavi2_Seg", sender: selectedPosts[indexPath.item])
            
        } else if selectedPosts[indexPath.row].purchaserShouldDo == Config.waitForValue && segmentIndex == 0 {
            self.performSegue(withIdentifier: "purchaseTransactionNavi3_Seg", sender: selectedPosts[indexPath.item])
            
        }  else if selectedPosts[indexPath.row].purchaserShouldDo == Config.buyFinish && segmentIndex == 1 {
            self.performSegue(withIdentifier: "purchaseTransactionNavi4_Seg", sender: selectedPosts[indexPath.item])
        }
    }
}

