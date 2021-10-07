//
//  CategoryPostsViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/05.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//
import UIKit
import SVProgressHUD

class CategoryPostsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uiViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uiView: UIView!
    
    let refreshControl = UIRefreshControl()
    var pullFlg = false
    var stopScrollFlg = false
    
    var page = 0
    var increaseNum = 0
    
    var category1: String!
    var selectedPosts = [Post]()
    var categoryPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        page = Config.page
        increaseNum = Config.increaseNum
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView?.alwaysBounceVertical = true
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.collectionView?.addSubview(refreshControl)
        
        uiView.isHidden = true
        
        loadAllPosts()
    }
    
    @objc func refresh() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        page = Config.page
        increaseNum = Config.increaseNum
        stopScrollFlg = false
        selectedPosts.removeAll()
        categoryPosts.removeAll()
        collectionView.reloadData()
        uiView.isHidden = true
        loadAllPosts()
    }
    
    func loadAllPosts() {
        
        var count = 0
        Api.Post.observeAllPosts { (post, postCount) in
            
            count += 1
            
            if let post = post {
                if post.category1 == self.category1 {
                    self.categoryPosts.append(post)
                }
                
            }
            
            if count == postCount {
                self.selectedPosts = self.categoryPosts.prefix(self.page).map {$0}
                
                if self.selectedPosts.count == 0 {
                    self.uiView.isHidden = false
                    self.uiViewHeightConstraint.constant = UIScreen.main.bounds.size.height
                    self.collectionViewHeightConstraint.constant = 0
                } else {
                    self.uiViewHeightConstraint.constant = 0
                    self.collectionViewHeightConstraint.constant = UIScreen.main.bounds.size.height
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !stopScrollFlg {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                self.stopScrollFlg = true
            }
            return;
        }
        
        
        if self.selectedPosts.count < self.page {
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
        
        var count = 0
        
        // increase page size
        page = page + increaseNum
        
        self.selectedPosts = self.categoryPosts.prefix(self.page).map {$0}
        
        if prepage >= selectedPosts.count {
            self.page = selectedPosts.count
            prepage = selectedPosts.count
            return;
        }
        
        self.collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let post = sender as? Post
            detailVC.postId = (post?.id)!
            
        }
    }
    
    func imageMargin(cell: PostCollectionViewCell, padding: CGFloat, marginWhere: String) -> PostCollectionViewCell {
        
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

extension CategoryPostsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPosts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
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

extension CategoryPostsViewController: UICollectionViewDelegateFlowLayout {
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
