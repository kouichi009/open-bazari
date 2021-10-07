//
//  FollowPostsViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class FollowPostsViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var page = 0
    var increaseNum = 0
    var pullFlg = false
    var reloadAllPostFlg = false
    var underPagePostFlg = false
    var neverCallPostAddedFlg = false
    var userId = String()
    var followingPosts = [Post]()
    var selectedPosts = [Post]()
    
    let refreshControl = UIRefreshControl()
    var noMoreFlg = false
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uiViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uiView: UIView!
    
    var feedPostExist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.collectionView?.addSubview(refreshControl)
        
        self.page = Config.page
        self.increaseNum = Config.page
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        Api.Feed.fetchCountPost(userId: userId) { (feedCount) in
            
            print(feedCount)
            if feedCount == 0 {
                self.setUiView()
                self.feedPostExist = false
            } else {
                self.setCollectionView()
                self.feedPostExist = true
                self.observeMyFeed()
            }
        }
        
        
    }
    
    func observeMyFeed() {
        
        initialize()
        var count = 0
        Api.Feed.observeFeed(userId: userId) { (post, postCount) in
            
            count += 1
            if let post = post {
                self.followingPosts.append(post)
            }
            
            if postCount == count {
                self.selectedPosts = self.followingPosts.prefix(self.page).map {$0}
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func initialize() {
        
        //初期化
        page = Config.page
        increaseNum = Config.increaseNum
        noMoreFlg = false
        self.selectedPosts.removeAll()
        self.followingPosts.removeAll()
        self.collectionView.reloadData()
        
        
    }
    
    func setCollectionView() {

        uiViewHeightConstraint.constant = 0
        uiView.isHidden = true
        collectionViewHeightConstraint.constant = self.view.frame.height
        self.collectionView.reloadData()
    }
    
    func setUiView() {
        uiViewHeightConstraint.constant = self.view.frame.height
        uiView.isHidden = false
        collectionViewHeightConstraint.constant = 0
    }
    
    
    @objc func refresh() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        if feedPostExist {
            self.observeMyFeed()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let post = sender as? Post
            detailVC.postId = (post?.id)!
            
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.selectedPosts.count == 0 {
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
            self.loadMoreselectedPosts()
        }
        
        if pullRatio == 0.0 {
            self.pullFlg = false
            
        }
        //      print("pullRation:\(pullRatio)")
    }
    
    
    func loadMoreselectedPosts() {
        
        if underPagePostFlg {
            
            if self.selectedPosts.count >= self.page {
                underPagePostFlg = false
            }
            return;
        }
        
        
        //prePage
        var prepage = page
        
        
        // increase page size
        page = page + increaseNum
        
        if prepage >= selectedPosts.count {
            page = selectedPosts.count
            self.selectedPosts = self.followingPosts
            self.collectionView.reloadData()
            noMoreFlg = true
            
            return;
        }
        
        SVProgressHUD.show()
        self.selectedPosts = self.followingPosts.prefix(self.page).map {$0}
        self.collectionView.reloadData()
        SVProgressHUD.dismiss()
    }
    

}


extension FollowPostsViewController : UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedPosts.count > 0 {
            return selectedPosts.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        
        
//        cell.post = self.selectedPosts[indexPath.item]
//        var cellWidth =  (collectionView.frame.size.width / 2 - 1)
//        print("indexItem ", indexPath.item)
//        var widCons: CGFloat = cellWidth / (cell.post?.ratios[0])!
//        
//        let padding = cellWidth - widCons
//        
//        if padding <= 0 {
//            cell.rightSideConstraint.constant = 0
//            cell.leftSideConstraint.constant = 0
//        } else {
//            cell.rightSideConstraint.constant = padding / 2
//            cell.leftSideConstraint.constant = padding / 2
//        }
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ビュー遷移時にタブバーを隠して、戻ってきたらタブバーを再表示させる方法
        self.performSegue(withIdentifier: "DetailSegue", sender: self.selectedPosts[indexPath.item])
    }
    
    
}

extension FollowPostsViewController: UICollectionViewDelegateFlowLayout {
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
