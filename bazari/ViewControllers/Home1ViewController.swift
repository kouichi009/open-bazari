//
//  Home1ViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import EMAlertController
import IQKeyboardManagerSwift

class Home1ViewController: UIViewController {
    
    var posts: [Post] = [Post]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var page = 0
    var increaseNum = 0
    var pullFlg = false
    var reloadAllPostFlg = false
    var underPagePostFlg = false
    var neverCallPostAddedFlg = false
    
    let refreshControl = UIRefreshControl()
    
    
    var viewHeight: CGFloat? {
        didSet {
            updateViewHeight()
        }
    }
    
    func updateViewHeight() {
        self.collectionView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.collectionView?.addSubview(refreshControl)
        
        self.page = Config.page
        self.increaseNum = Config.page
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        Api.Post.observeRemovePost { (post) in
            
            var count = 0
            
            for pos in self.posts {
                
                if let post = post {
                    if pos.id == post.id {
                        self.posts.remove(at: count)
                        self.collectionView?.reloadData()
                        
                    }
                }
                count += 1
            }
        }
        
        Api.Post.observeChangePost { (post) in
            var count = 0
            
            for pos in self.posts {
                
                if let post = post {
                    if pos.id == post.id {
                        self.posts[count] = post
                        self.collectionView?.reloadData()
                        
                    }
                }
                count += 1
            }
        }
        
        fetchPosts()
    }
    
    
    
    @objc func refresh() {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        if !neverCallPostAddedFlg {
            fetchPosts()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    
    func fetchPosts() {
        
        var count = 0
        
        Api.Post.fetchCountPost { (countPost) in
            
            
            if countPost < self.page && countPost != 0 {
                
                self.observePost()
                self.underPagePostFlg = true
                return;
                
            } else if countPost == 0 {
                self.underPagePostFlg = true
                return;
                
            } else {
                self.observePost()
            }
        }
    }
    
    func observePost() {
        
        if !neverCallPostAddedFlg {
            var count = 0
            Api.Post.fetchCountPost { (postCount) in
                
                print(postCount)
                if postCount == 0 {
                    return;
                }
                Api.Post.observePostsAdded(completion: { (post) in
                    
                    if self.neverCallPostAddedFlg {
                        
                        if let post = post {
                            self.posts.insert(post, at: 0)
                        }
                        self.collectionView?.reloadData()
                        return;
                    }
                    
                    count += 1
                    
                    if postCount < self.page {
                        
                        if let post = post {
                            self.posts.insert(post, at: 0)
                        }
                        
                        if postCount == count {
                            
                            self.collectionView?.reloadData()
                            self.neverCallPostAddedFlg = true
                            return;
                        }
                        return;
                    }
                    
                    let ptCount = postCount - self.page
                    
                    if count > ptCount && ptCount >= 0 {
                        
                        if let post = post {
                            self.posts.insert(post, at: 0)
                        }
                        
                        if count == postCount {
                            print("self.posts.count \(self.posts.count)")
                            
                            self.collectionView?.reloadData()
                            self.neverCallPostAddedFlg = true
                        }
                    }
                })
            }
        }
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
        
        if self.posts.count == 0 {
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
        //      print("pullRation:\(pullRatio)")
    }
    
    
    func loadMorePosts() {
        
        if underPagePostFlg {
            
            if self.posts.count >= self.page {
                underPagePostFlg = false
            }
            return;
        }
        
        
        //prePage
        var prepage = page
        
        var count = 0
        
        // increase page size
        page = page + increaseNum
        
        //        let blockUsers = self.userDefaults.array(forKey: Config.BLOCK_USERS)
        
        Api.Post.observeTopPosts(page: self.page) { (post, postCount) in
            
            
            if prepage >= postCount {
                self.page = postCount
                prepage = postCount
                self.reloadAllPostFlg = true
                return;
            }
            
            if self.reloadAllPostFlg {
                
                ProgressHUD.show("少々おまちください。")
                count += 1
                
                if count == 1 {
                    self.posts.removeAll()
                }
                
                if let post = post {
                    self.posts.append(post)
                }
                
                print("count \(count)")
                print("postCount \(postCount)")
                print("posts.count ", self.posts.count)
                if postCount == count {
                    
                    self.collectionView?.reloadData()
                    ProgressHUD.showSuccess("読み込み完了")
                    self.reloadAllPostFlg = false
                    return;
                } else {
                    return;
                }
            }
            
            SVProgressHUD.show()
            
            
            count += 1
            print("count \(count)")
            print("prepage \(prepage)")
            
            
            
            if count > prepage {
                
                if let post = post {
                    self.posts.append(post)
                }
            }
            
            if count == postCount {
                self.collectionView?.reloadData()
                SVProgressHUD.dismiss()
            }
            
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

extension Home1ViewController : UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.count > 0 {
            return posts.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        
        cell.post = self.posts[indexPath.item]
        
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
        self.performSegue(withIdentifier: "DetailSegue", sender: self.posts[indexPath.item])
    }
    
    
}

extension Home1ViewController: UICollectionViewDelegateFlowLayout {
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
