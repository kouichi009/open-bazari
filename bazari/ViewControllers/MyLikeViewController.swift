//
//  MyLikeViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/30.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import BadgeSegmentControl

class MyLikeViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: BadgeSegmentControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var sellPosts = [Post]()
    var soldPosts = [Post]()
    var selectedPosts = [Post]()
    
    var currentUid = String()
    
    var page = 0
    var increaseNum = 0
    var pullFlg = false
    var reloadAllPostFlg = false
    var neverCallPostAddedFlg = false
    
    let refreshControl = UIRefreshControl()
    
    let firstSegmentName = "販売中"
    let secondSegmentName = "売り切れ"
    
    var segmentIndex = Int()
    
    var noMoreFlg = false
    
    
    //    var myPostExistFlg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setSegmentControl()
        
        self.collectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
        
        page = Config.page
        increaseNum = Config.increaseNum
        
        
        self.title = "いいね！した商品"
        
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
        
    }
    
    
    
    @objc func refresh() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        loadAllPosts()
        
    }
    
    func initialize() {
        
        //初期化
        page = Config.page
        increaseNum = Config.increaseNum
        noMoreFlg = false
        self.selectedPosts.removeAll()
        self.sellPosts.removeAll()
        self.soldPosts.removeAll()
        self.collectionView.reloadData()
        
        
    }
    
    func loadAllPosts() {
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        
        initialize()
        
        var count = 0
        
        Api.MyLikePosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in
            
            count += 1
            
            if let post = post {
                
                if post.transactionStatus == Config.sell {
                    self.sellPosts.append(post)
                    
                } else if post.transactionStatus == Config.transaction || post.transactionStatus == Config.sold {
                    self.soldPosts.append(post)
                }
            }
            
            
            if postCount == count {
                
                switch self.segmentIndex {
                    
                case 0:
                    
                    self.selectedPosts = self.sellPosts.prefix(self.page).map {$0}
                    
                case 1:
                    self.selectedPosts = self.soldPosts.prefix(self.page).map {$0}
                    
                default:
                    print("t")
                    
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.selectedPosts.count < self.page  {
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
        if pullRatio >= 0.5 && !pullFlg {
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
        var prepage = page
        
        
        // increase page size
        page = page + increaseNum
        
        if prepage >= selectedPosts.count {
            page = selectedPosts.count
            
            switch self.segmentIndex {
                
            case 0:
                
                self.selectedPosts = self.sellPosts
                
            case 1:
                self.selectedPosts = self.soldPosts
                
            default:
                print("t")
                
            }
            
            self.collectionView.reloadData()
            noMoreFlg = true
            
            return;
        }
        
        SVProgressHUD.show()
        
        switch self.segmentIndex {
            
        case 0:
            
            self.selectedPosts = self.sellPosts.prefix(self.page).map {$0}
            
        case 1:
            self.selectedPosts = self.soldPosts.prefix(self.page).map {$0}
            
        default:
            print("t")
            
        }
        self.collectionView.reloadData()
        SVProgressHUD.dismiss()
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let post = sender as! Post
            detailVC.postId = post.id!
            
        }
    }
    
    func imageMargin(cell: PostCollectionViewCell, padding: CGFloat, marginWhere: String) -> PostCollectionViewCell {
        
        print("padding \(padding)")
        
        if marginWhere == "side" {
            cell.topConstraint.constant = 0
            cell.bottomConstraint.constant = 0
            cell.leftSideConstraint.constant = padding / 2
            cell.rightSideConstraint.constant = padding / 2
        } else if (marginWhere == "top") {
            cell.topConstraint.constant = padding / 2
            cell.bottomConstraint.constant = padding / 2
            cell.leftSideConstraint.constant = 0
            cell.rightSideConstraint.constant = 0
        }
        
        return cell
    }
}

extension MyLikeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedPosts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        
        
        cell.post = self.selectedPosts[indexPath.item]
       
        var widthCons = CGFloat()
        var cellWidth =  (collectionView.frame.size.width / 2 - 1)
        var dic: Dictionary<String, CGFloat> = (cell.post?.thumbnailRatio)!
        if dic[Config.ratioWidthKey]! > 1 {
            widthCons = cellWidth / dic[Config.ratioWidthKey]!
            let padding = cellWidth - widthCons
            return imageMargin(cell: cell, padding: padding, marginWhere: "side")
        }
        
        widthCons = cellWidth / dic[Config.ratioHeightKey]!
        let padding = cellWidth - widthCons
        return imageMargin(cell: cell, padding: padding, marginWhere: "top")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ビュー遷移時にタブバーを隠して、戻ってきたらタブバーを再表示させる方法
        self.performSegue(withIdentifier: "DetailSegue", sender: self.selectedPosts[indexPath.item])
    }
}

extension MyLikeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 1, height: (collectionView.frame.size.width / 2 - 1) + 76)
    }
}
