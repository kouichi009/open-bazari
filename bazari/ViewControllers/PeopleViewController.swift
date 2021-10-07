//
//  PeopleViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class PeopleViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var usermodels: [UserModel] = []
    var isBlockedFlgs: [Bool] = []
    var page = 30
    var increaseNum = 30
    var pullFlg = false
    var reloadAllPostFlg = false
    var underPagePostFlg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        loadUsers()
    }
    
    func loadUsers() {
        
        self.usermodels.removeAll()
        self.tableView.reloadData()
        var count = 0
        Api.User.observeUsersPage(page: page) { (usermodel, userCount) in
            self.isFollowing(userId: usermodel.id!, completed: { (value) in
                usermodel.isFollowing = value
                
                self.isBlocked(userId: usermodel.id!, completed: { (value) in
                    
                    count += 1
                    
                    if Api.User.CURRENT_USER?.uid != usermodel.id {
                        self.usermodels.insert(usermodel, at: 0)
                        self.isBlockedFlgs.insert(value, at: 0)
                    }
                    
                    if count == userCount {
                        self.tableView.reloadData()
                        
                        if userCount < self.page {
                            self.underPagePostFlg = true
                        }
                    }
                })
            })
        }
    }
    
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
//    func isBlocking(userId: String, completed: @escaping(Bool) -> Void) {
//        Api.Block.isBlocking(userId: userId, completion: completed)
//    }

    func isBlocked(userId: String, completed: @escaping(Bool) -> Void) {
        Api.Block.isBlocked(currentUid: (Api.User.CURRENT_USER?.uid)!, userId: userId, completion: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfileUser_Seg" {
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileUserVC.userId = userId
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.usermodels.count == 0 {
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
        
        if self.usermodels.count == 0 {
            return;
        }
        
        if underPagePostFlg {
            
            if self.usermodels.count >= self.page {
                underPagePostFlg = false
            }
            return;
        }
        
        //prePage
        var prepage = page
        
        
        // increase page size
        page = page + increaseNum
        
        var count = 0
        Api.User.observeUserLoadMore(page: self.page) { (usermodel, userCount) in
            
            self.isFollowing(userId: usermodel.id!, completed: { (value) in
                usermodel.isFollowing = value
                
                self.isBlocked(userId: usermodel.id!, completed: { (valueBlocked) in
                    
                    count += 1
                    self.appendUserModel(count: count, prepage: prepage, userCount: userCount, valueBlocked: valueBlocked, usermodel: usermodel)
                    
                })
            })
        }
    }
    
    func appendUserModel(count: Int, prepage: Int, userCount: Int, valueBlocked: Bool, usermodel: UserModel) {
        
        
        if prepage >= userCount {
            self.page = userCount
            self.reloadAllPostFlg = true
            return;
        }
        
        if self.reloadAllPostFlg {
            
            ProgressHUD.show("少々おまちください。")
            
            if count == 1 {
                self.usermodels.removeAll()
            }
            self.usermodels.append(usermodel)
            self.isBlockedFlgs.append(valueBlocked)
            
            if userCount == count {
                ProgressHUD.showSuccess("読み込み完了")
                self.reloadAllPostFlg = false
                return;
            } else {
                return;
            }
        }
        
        SVProgressHUD.show()
        
        
        print("count \(count)")
        print("prepage \(prepage)")
        
        
        
        if count > prepage {
            self.usermodels.append(usermodel)
            self.isBlockedFlgs.append(valueBlocked)
        }
        
        if count == userCount {
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    
}
extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usermodels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        
        let usermodel = usermodels[indexPath.row]
        let isBlockedFlg = isBlockedFlgs[indexPath.row]
        cell.usermodel = usermodel
        cell.isBlockedFlg = isBlockedFlg
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.usermodels.count > 0 {
            let usermodel = usermodels[indexPath.row]
            performSegue(withIdentifier: "goToProfileUser_Seg", sender: usermodel.id)
            
        }
    }
    
}

