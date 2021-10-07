//
//  Category_BrandViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class Category_BrandViewController: UIViewController {
    
    var category_brand = String()
    var category_brandName = String()
    var selectedPosts = [Post]()
    var cate_brandPosts = [Post]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var page = 0
    var increaseNum = 0
    var pullFlg = false
    var reloadAllPostFlg = false
    var underPagePostFlg = false
    var neverCallPostAddedFlg = false
    
    let refreshControl = UIRefreshControl()
    var stopScrollFlg = false

    
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
        
        self.title = category_brandName
        
        
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
        cate_brandPosts.removeAll()
        collectionView.reloadData()
        loadAllPosts()
        
    }
    
    func loadAllPosts() {
        
        var count = 0
        Api.Post.observeAllPosts { (post, postCount) in
            
            count += 1
            
            if let post = post {
                
                switch self.category_brand {
                case Config.CATEGORY1:
                    if self.category_brandName == post.category1 {
                        self.cate_brandPosts.append(post)
                    }
                    break;
                case Config.CATEGORY2:
                    if self.category_brandName == post.category2 {
                        self.cate_brandPosts.append(post)
                    }
                    break;
                case Config.BRAND:
                    if self.category_brandName == post.brand {
                        self.cate_brandPosts.append(post)
                    }
                    
                    break;
                default:
                    break;
                }
                
            }
            
            if postCount == count {
                
                switch self.category_brand {
                case Config.CATEGORY1:
                    
                    self.selectedPosts = self.cate_brandPosts.prefix(self.page).map {$0}
                    break;
                case Config.CATEGORY2:
                    
                    
                    self.selectedPosts = self.cate_brandPosts.prefix(self.page).map {$0}
                    break;
                case Config.BRAND:
                    
                    self.selectedPosts = self.cate_brandPosts.prefix(self.page).map {$0}
                    break;
                default:
                    break;
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    
    
    
   
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !stopScrollFlg {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                self.stopScrollFlg = true
            }
            return;
        }
        
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
            self.loadMorePosts()
        }
        
        if pullRatio == 0.0 {
            self.pullFlg = false
            
        }
        //      print("pullRation:\(pullRatio)")
    }
    
    
    func loadMorePosts() {
        
        
        //prePage
        var prepage = page
        
        var count = 0
        
        // increase page size
        page = page + increaseNum
        
        self.selectedPosts = self.cate_brandPosts.prefix(self.page).map {$0}
        
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

extension Category_BrandViewController : UICollectionViewDataSource, UICollectionViewDelegate
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

extension Category_BrandViewController: UICollectionViewDelegateFlowLayout {
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
