//
//  DraftPostsViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class DraftPostsViewController: UIViewController {
    
    var draftPost = Post()
    var draftPosts = [Post]()
    var currentUid = String()
    var draftPostExistFlg = false
    var noItemCount = Int()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    func initialize() {
        
        //初期化
        draftPostExistFlg = false
        noItemCount = 0
        draftPosts.removeAll()
        draftPost = Post()
        self.tableView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        initialize()
        
        SVProgressHUD.show()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        Api.DraftPost.fetchMyDraftCount(userId: self.currentUid) { (draftCount) in
            
            
            if draftCount == 0 {
                self.draftPostExistFlg = false
                self.noItemCount = 0
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            } else {
                self.draftPostExistFlg = true
                self.observeMyDraft()
                
            }
        }
        }
    }
    
    func observeMyDraft() {
        var count = 0
        Api.DraftPost.observeMyDraftPost(userId: self.currentUid) { (post, postCount) in
            count += 1
            
            if let post = post {
                self.draftPosts.append(post)
                
            }
            
            
            if count == postCount {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        }
    }
    
    func draftPost(draftPost: Post?) {

        
        SVProgressHUD.show()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            
            var array = [UIImage]()
            
            if let draftPost = draftPost {
                let imageUrls = draftPost.imageUrls
                
                for imageUrl in imageUrls {
                    let url = URL(string: imageUrl)
                    if let data = try? Data(contentsOf: url!) {
                        let image: UIImage = UIImage(data: data)!
                        array.append(image)
                    }
                }
                
                SVProgressHUD.dismiss()
                self.draftPost = draftPost
                self.performSegue(withIdentifier: "DraftToNewPost_Seg", sender: array)
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DraftToNewPost_Seg" {
            let draftVC = segue.destination as! DraftToNewPostViewController
            let images = sender as? [UIImage]
            
            var count = 0
            var tupleArray: [(image: UIImage, sort: Int)] = []
            images?.forEach({ (image) in
                tupleArray.append((image: image, sort: count))
                count += 1
            })
            draftVC.tupleImages = tupleArray
            draftVC.post = self.draftPost
            
        }
    }
}

extension DraftPostsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if draftPostExistFlg {
            return draftPosts.count
        } else {
            return self.noItemCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DraftPostTableViewCell", for: indexPath) as! DraftPostTableViewCell
        
        
        if draftPostExistFlg {
            let post = draftPosts[indexPath.row]
            cell.post = post
            return cell
        } else {
            cell.productImageView.image = nil
            cell.productTitleLbl.text = "下書き中の商品はありません。"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if draftPostExistFlg {
            self.draftPost(draftPost: draftPosts[indexPath.row])
        }
    }
}
