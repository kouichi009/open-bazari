//
//  SellNavi1ViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SellNavi1ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var post: Post?
    var address: Address?
    var usermodel: UserModel?
    var currentUserModel: UserModel?
    var chats = [Chat]()
    
    var currentUid = String()
    
    var delegate: ReloadNotificationDelegate?
    var timerOffFlg = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        delegate = HelperService.notiVC
        
        self.title = (post?.title)!
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
            
        }
        
        load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerOffFlg = true
        self.tableView.reloadData()
        print("view Will Disappear")
        
    }
    
    func load() {
        
        var count = 0
        Api.User.observeAllUsers(completion: { (usermodel, usercount) in
            
            count += 1
            
            if let purchaserUid = self.post?.purchaserUid {
                
                if let usermodel = usermodel {
                    if usermodel.id == purchaserUid {
                        self.usermodel = usermodel
                    } else if usermodel.id == self.currentUid {
                        self.currentUserModel = usermodel
                    }
                    
                }
                
                if count == usercount {
                    self.tableView.reloadData()
                }
            }
            
            
        })
        
        if let purchaserUid = self.post?.purchaserUid {
            Api.Address.observeAddress(userId: purchaserUid) { (address) in
                
                if let address = address {
                    self.address = address
                    self.tableView.reloadData()
                }
            }
        }
        
        
        
        self.chats.removeAll()
        self.tableView.reloadData()
        
        var count2 = 0
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "発送した", style: .default, handler: {(alert: UIAlertAction!) in
            self.shipNoti()
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            //発送通知ボタンを有効化する
            self.tableView.reloadData()
        })
        
        
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func shipNoti() {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        self.setNotifications(post: self.post)
        
        
        Api.Post.REF_POSTS.child((post?.id)!).updateChildValues(["shippedDateTimestamp": timestamp,Config.sellerShouldDo: Config.waitCatch, Config.purchaserShouldDo: Config.catchProduct]) { (error, ref) in
            
            Api.MySellPosts.REF_MYSELL.child(self.currentUid).child((self.post?.id)!).updateChildValues(["timestamp": timestamp])
            Api.MyPurchasePosts.REF_MYPURCHASE.child((self.post?.purchaserUid)!).child((self.post?.id)!).updateChildValues(["timestamp": timestamp])
            
            
            
            self.delegate?.reloadNotification()
            _ = self.navigationController?.popViewController(animated: true)
            
            
        }
        
        if let fcmToken = usermodel?.fcmToken {
            sendPushNotification(token: fcmToken)
        }
    }
}

extension SellNavi1ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        //  return UITableViewAutomaticDimension
        
        switch indexPath.section {
        case 0:
            return 86
        case 1:
            return 295
        case 2:
            return 333
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
        
        if post != nil && post != nil && address != nil && usermodel != nil {
            
            if section == 4 {
                return self.chats.count
            } else {
                return 1
            }
        } else {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShipDeadLineSellerNaviTableViewCell", for: indexPath) as! ShipDeadLineSellerNaviTableViewCell
            cell.shipAlertBtn.isEnabled = true
            cell.delegate = self
            cell.timerOffFlg = timerOffFlg
            cell.post = post
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressNaviTableViewCell", for: indexPath) as! AddressNaviTableViewCell
            cell.post = post
            cell.address = address
            return cell
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TorihikiNaviTableViewCell", for: indexPath) as! TorihikiNaviTableViewCell
            
            return cell
        }
        
        if indexPath.section == 4{
            
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
            cell.label1.text = "購入者情報"
            return cell
        }
        
        
        
        
        
        return UITableViewCell()
    }
    
    
}

extension SellNavi1ViewController: MessageInputTextViewNaviTableViewCellDelegate, ShipDeadLineSellerNaviTableViewCellDelegate, YouInfoNaviTableViewCellDelegate {
    
    
    
    func back() {
        
        self.showAlert(title: "商品の発送は終わっていますか？", message: "必ず商品の発送が終わってから発送通知を行なってください。")
        
    }
    
    func sendPushNotification(token: String) {
        
        let indexNum = Config.pushNotiTitleCount
        
        guard let post = post else {return}
        var titleStr: String = post.title!
        
        if titleStr.count > indexNum {
            titleStr = String(titleStr.prefix(indexNum))
            titleStr = titleStr+"..."
        }
        let message = "「\(titleStr)」が発送されました。商品が到着したら受取通知を行ってください。"
        
        Api.Notification.sendNotification(token: token, message: message) { (success, error) in
            if success == true {
                print("Notification sent!")
            } else {
                print("Notification sent error!")
            }
        }
    }
    
    func setNotifications(post: Post?) {
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
        let timestamp = Int(Date().timeIntervalSince1970)
        let newNotificationReference = Api.Notification.REF_NOTIFICATION
        let newMyNotificationReference = Api.Notification.REF_MYNOTIFICATION.child((self.post?.purchaserUid)!)
        let newNotificationId = newNotificationReference.childByAutoId().key
        
        newNotificationReference.child(newNotificationId!).setValue(["checked": false, "from": currentUid, "objectId": (post?.id)!, "type": Config.naviShip, "timestamp": timestamp, "to": (post?.purchaserUid)!, "segmentType": Config.transaction]) { (error, ref) in
            
        }
        newMyNotificationReference.child(newNotificationId!).setValue(["timestamp": timestamp])
        
    }
    
    func pressSendMessage() {
        
        print(currentUid)
        
        
        
        self.load()
        
    }
    
    
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
    
}





