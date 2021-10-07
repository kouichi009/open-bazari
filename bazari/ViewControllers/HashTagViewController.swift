//
//  HashTagViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/12.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class HashTagViewController: UIViewController {

    var tag = ""
    var posts = [Post]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.alwaysBounceVertical = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.title = "\(tag)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPosts()

    }
    
    func loadPosts() {
        posts.removeAll()
        self.collectionView.reloadData()
        
        if tag.hasPrefix("#") {
            tag = tag.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        }
        
        var count = 0
        Api.HashTag.observeHashTagPosts(withTag: tag) { (post, postCount) in
            count += 1
            
            if let post = post {
                self.posts.append(post)
            }
            
            if postCount == count {
                self.collectionView.reloadData()
            }
          
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let post = sender as! Post
            detailVC.postId = post.id!
            
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

extension HashTagViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        
        cell.post = self.posts[indexPath.item]
        
        var widthCons = CGFloat()
        let cellWidth =  (collectionView.frame.size.width / 2 - 1)
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

extension HashTagViewController: UICollectionViewDelegateFlowLayout {
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
