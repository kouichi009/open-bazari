//
//  SellTransactionViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import BadgeSegmentControl

class SellTransactionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentControl: BadgeSegmentControl!
    
    var sellPosts = [Post]()
    var transactionPosts = [Post]()
    var soldPosts = [Post]()
    var selectedPosts = [Post]()
    
    var currentUid = String()
    
    var pageForTable = 0
    var increaseNumForTable = 0
    var pullFlg = false
    //    var reloadAllPostFlg = false
    var underPagePostFlg = false
    var neverCallPostAddedFlg = false
    
    let refreshControl = UIRefreshControl()
    
    let firstSegmentName = "出品中"
    let secondSegmentName = "取引中"
    let thirdSegmentName = "売却済"
    
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
        
        self.title = "出品した商品"
        Api.MySellPosts.fetchCountMySellPosts(userId: currentUid) { (myPostCount) in
            
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
        self.segmentControl.updateBadge(forValue: 0, andSection: 1)
        self.selectedPosts.removeAll()
        self.transactionPosts.removeAll()
        self.soldPosts.removeAll()
        self.sellPosts.removeAll()
        self.tableView.reloadData()
    }
    
    func loadAllPosts() {
        
        if myPostExistFlg == false {
            return
        }
        
        initialize()
        
        var count = 0
        
        Api.MySellPosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in
            
            count += 1
            if let post = post {
                switch post.transactionStatus {
                case Config.sell:
                    self.sellPosts.append(post)
                    break;
                case Config.transaction:
                    self.transactionPosts.append(post)
                    if post.sellerShouldDo == Config.ship || post.sellerShouldDo == Config.valueBuyer {
                        self.badgeCount += 1
                        self.segmentControl.updateBadge(forValue: self.badgeCount, andSection: 1)
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
                    
                    self.selectedPosts = self.sellPosts.prefix(self.pageForTable).map {$0}
                    
                case 1:
                    self.selectedPosts = self.transactionPosts.prefix(self.pageForTable).map {$0}
                    
                    
                case 2:
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
        self.segmentControl.addSegmentWithTitle(self.thirdSegmentName)
        
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
        if selectedPosts.count < Config.pageForTable {
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
        
        let prepage = pageForTable
        
        pageForTable = pageForTable + increaseNumForTable
        
        if prepage > selectedPosts.count {
            
            pageForTable = selectedPosts.count
            
            switch self.segmentIndex {
                
            case 0:
                
                self.selectedPosts = self.sellPosts
                
            case 1:
                self.selectedPosts = self.transactionPosts
                
            case 2:
                self.selectedPosts = self.soldPosts
                
            default:
                print("t")
                
            }
            
            self.tableView.reloadData()
            // ProgressHUD.showSuccess("ロード完了")
            noMoreFlg = true
            
            print(selectedPosts.count)
            print(pageForTable)
            return;
        }
        
        SVProgressHUD.show()
        
        switch self.segmentIndex {
            
        case 0:
            
            self.selectedPosts = self.sellPosts.prefix(self.pageForTable).map {$0}
            
        case 1:
            self.selectedPosts = self.transactionPosts.prefix(self.pageForTable).map {$0}
            
        case 2:
            self.selectedPosts = self.soldPosts.prefix(self.pageForTable).map {$0}
            
        default:
            print("t")
            
        }
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        
        if segue.identifier == "sellTransactionNavi3_Seg" {
            
            let sellNaviVC = segue.destination as! SellNavi3ViewController
            let post  = sender as? Post
            sellNaviVC.post = post
        }
        
        if segue.identifier == "sellTransactionNavi4_Seg" {
            
            let sellNaviVC = segue.destination as! SellNavi4ViewController
            let post  = sender as? Post
            sellNaviVC.post = post
        }
        
        if segue.identifier == "DetailSegue" {
            
            let detailVC = segue.destination as! DetailViewController
            let postId  = sender as! String
            detailVC.postId = postId
        }
        
    }
    
}

extension SellTransactionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SellListTableViewCell", for: indexPath) as! SellListTableViewCell
        cell.post = self.selectedPosts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if selectedPosts[indexPath.row].sellerShouldDo == Config.ship && segmentIndex == 1 {
            self.performSegue(withIdentifier: "sellTransactionNavi1_Seg", sender: selectedPosts[indexPath.item])
        } else if selectedPosts[indexPath.row].sellerShouldDo == Config.waitCatch && segmentIndex == 1 {
            self.performSegue(withIdentifier: "sellTransactionNavi2_Seg", sender: selectedPosts[indexPath.item])
        }  else if selectedPosts[indexPath.row].sellerShouldDo == Config.valueBuyer && segmentIndex == 1 {
            self.performSegue(withIdentifier: "sellTransactionNavi3_Seg", sender: selectedPosts[indexPath.item])
            
        } else if selectedPosts[indexPath.row].sellerShouldDo == Config.soldFinish && segmentIndex == 2 {
            self.performSegue(withIdentifier: "sellTransactionNavi4_Seg", sender: selectedPosts[indexPath.item])
        } else {
            //販売中
            self.performSegue(withIdentifier: "DetailSegue", sender: selectedPosts[indexPath.item].id)
        }
    }
}

