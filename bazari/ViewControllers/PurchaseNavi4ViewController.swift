//
//  PurchaseNavi4ViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/08.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class PurchaseNavi4ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var post: Post?
    var usermodel: UserModel?
    var currentUserModel: UserModel?
    var chats = [Chat]()
    
    var currentUid = String()
    
    var value: Value?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        
        tableView.dataSource = self
        tableView.delegate = self
        self.title = (post?.title)!
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
            
        }
        Api.SoldOut.observeSoldOutPost(postId: (post?.id)!) { (post) in
            self.post = post
            self.load()
        }
    }
    
    func load() {
        
        
        var count = 0
        Api.User.observeAllUsers(completion: { (usermodel, usercount) in
            
            count += 1
            
            if let usermodel = usermodel {
                if usermodel.id == self.post?.uid {
                    self.usermodel = usermodel
                } else if usermodel.id == self.currentUid {
                    self.currentUserModel = usermodel
                }
            }
            
            if count == usercount {
                self.tableView.reloadData()
            }
        })
        
        Api.Value.fetchUserValues(userId: currentUid) { (value, valueCount) in
            
            if let value = value {
                if value.postId == self.post?.id {
                    self.value = value
                    self.tableView.reloadData()
                }
            }
        }
        
        var count2 = 0
        
        self.chats.removeAll()
        self.tableView.reloadData()
        
        Api.Chat.observeChats(postId: (post?.id)!) { (chat, chatCount) in
            
            count2 += 1
            
            if let chat = chat {
            self.chats.insert(chat, at: 0)
            }
            if count2 == chatCount {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToValueVC_Seg" {
            
            let valueVC = segue.destination as! ValueViewController
            let userId  = sender as! String
            valueVC.userId = userId
        }
        
        if segue.identifier == "goToProfileUserSeg" || segue.identifier == "goToProfileUserSeg_iPhoneSE"  {

            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId  = sender as! String
            profileUserVC.userId = userId
        }
    }
}

extension PurchaseNavi4ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        
        switch indexPath.section {
        case 0:
            return 86
        case 1:
            return 265
        case 2:
            return 65
        case 3:
            return 44
        case 4:
            
            return UITableViewAutomaticDimension
        case 5:
            return 178
        case 6:
            return 90
        default:
            print("t")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if post != nil && value != nil && usermodel != nil {
            
            if section == 4 {
                return self.chats.count
            } else {
                return 1
            }
        } else {
            print(post)
            print(value)
            print(usermodel)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductInfoNaviTableViewCell", for: indexPath) as! ProductInfoNaviTableViewCell
            cell.post = post
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NaviFinalTableViewCell", for: indexPath) as! NaviFinalTableViewCell
            cell.post = post
            cell.value = value
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressNaviTableViewCell", for: indexPath) as! AddressNaviTableViewCell
            cell.post = post
            return cell
        }
        
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TorihikiNaviTableViewCell", for: indexPath) as! TorihikiNaviTableViewCell
            
            return cell
        }
        
        if indexPath.section == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatNaviTableViewCell", for: indexPath) as! ChatNaviTableViewCell
            
            cell.chat = chats[indexPath.row]
            
            if chats[indexPath.row].uid == currentUid {
                cell.usermodel = self.currentUserModel
            } else {
                cell.usermodel = self.usermodel
            }
            
            return cell
            
        }
        
        if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInputTextViewNaviTableViewCell", for: indexPath) as! MessageInputTextViewNaviTableViewCell
            cell.delegate = self
            cell.usermodel = usermodel
            cell.post = post
            return cell
        }
        
        
        
        if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YouInfoNaviTableViewCell", for: indexPath) as! YouInfoNaviTableViewCell
            cell.usermodel = usermodel
            cell.delegate = self
            cell.label1.text = "販売者情報"
            return cell
        }
        
        
        
        
        
        return UITableViewCell()
    }
    
    
}

extension PurchaseNavi4ViewController: MessageInputTextViewNaviTableViewCellDelegate, YouInfoNaviTableViewCellDelegate {

    func goToValueVC(userId: String) {
        self.performSegue(withIdentifier: "goToValueVC_Seg", sender: userId)
    }
    
    func goToUserVC(userId: String) {
        
        if Config.isUnderIphoneSE {
            performSegue(withIdentifier: "goToProfileUserSeg_iPhoneSE", sender: userId)
            
        } else {
            performSegue(withIdentifier: "goToProfileUserSeg", sender: userId)
        }
        
    }
    
    
    func pressSendMessage() {
        
        self.load()
    }
}
