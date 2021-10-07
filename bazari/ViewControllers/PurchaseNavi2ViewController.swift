//
//  PurchaseNavi2ViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import DLRadioButton

class PurchaseNavi2ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var post: Post?
    var address: Address?
    var usermodel: UserModel?
    var currentUserModel: UserModel?
    var chats = [Chat]()
    
    var currentUid = String()
    
    var delegate: ReloadNotificationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = HelperService.notiVC
        
        self.tabBarController?.tabBar.isHidden = true
        
        
        tableView.dataSource = self
        tableView.delegate = self
        self.title = (post?.title)!
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
            
        }
        
        load()
    }
    
    func load() {
        Api.Post.observePost(postId: (post?.id)!) { (post) in
            
            if let post = post {
                
                
                self.post = post
                
                var count = 0
                Api.User.observeAllUsers(completion: { (usermodel, usercount) in
                    
                    count += 1
                    if let usermodel = usermodel {
                        if usermodel.id == post.uid {
                            self.usermodel = usermodel
                        } else if usermodel.id == self.currentUid {
                            self.currentUserModel = usermodel
                        }
                    }
                    
                    if count == usercount {
                        self.tableView.reloadData()
                    }
                })
            }
        }
        Api.Address.observeAddress(userId: currentUid) { (address) in
            
            if let address = address {
                self.address = address
                self.tableView.reloadData()
            }
        }
        
        var count = 0
        
        self.chats.removeAll()
        self.tableView.reloadData()
        
        Api.Chat.observeChats(postId: (post?.id)!) { (chat, chatCount) in
            
            count += 1
            if let chat = chat {
                self.chats.insert(chat, at: 0)
            }
            
            if count == chatCount {
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
            let userId = sender as! String
            profileUserVC.userId = userId
        }
    }
    
    func showAlert(title: String, message: String, valueStatus: String, valueComment: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let OKAction = UIAlertAction(title: "評価を投稿する", style: .default, handler: {(alert: UIAlertAction!) in
            self.evaluateTransaction(valueStatus: valueStatus, valueComment: valueComment)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            //評価ボタンを有効化する
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
    
    func evaluateTransaction(valueStatus: String, valueComment: String) {
        //いいね、購入時の良い評価、売却時の良い評価どれか一つでもつけてくれたら、次アプリを起動した時に、
        //アプリのレビューに誘導する。 誘導したらカウントを消去。すでにアプリを評価したら二度とアラートを出さない。
        //評価してくれない場合、しばらくカウントを続けてまた誘導。
        if valueStatus == Config.sun {
            let userDefaults = UserDefaults.standard
            let evaCount: Int = userDefaults.integer(forKey: Config.count_forEvaluateApp) + 1
            userDefaults.set(evaCount, forKey: Config.count_forEvaluateApp)
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let autoId = Api.Value.REF_MYVALUE.child((usermodel?.id)!).childByAutoId().key
        Api.Value.REF_MYVALUE.child((usermodel?.id)!).child(autoId!).setValue(["timestamp": timestamp])
        
        Api.Value.REF_VALUE.child(autoId!).setValue(["valueStatus": valueStatus, "valueComment": valueComment, "from": currentUid, "type": "sell", "postId": (post?.id)!, "timestamp": timestamp])
        
        if valueStatus == Config.sun {
            var sunCount = (usermodel?.sun)!
            sunCount += 1
            Api.User.REF_USERS.child((usermodel?.id)!).child("value").updateChildValues([valueStatus: sunCount])
        } else if valueStatus == Config.cloud {
            var cloudCount = (usermodel?.cloud)!
            cloudCount += 1
            Api.User.REF_USERS.child((usermodel?.id)!).child("value").updateChildValues([valueStatus: cloudCount])
        } else {
            var rainCount = (usermodel?.rain)!
            rainCount += 1
            Api.User.REF_USERS.child((usermodel?.id)!).child("value").updateChildValues([valueStatus: rainCount])
        }
        
        
        
        Api.Post.REF_POSTS.child((post?.id)!).updateChildValues([Config.sellerShouldDo: Config.valueBuyer,Config.purchaserShouldDo: Config.waitForValue , "transactionStatus": Config.transaction], withCompletionBlock: { (error, ref) in
            
            Api.MySellPosts.REF_MYSELL.child((self.post?.uid)!).child((self.post?.id)!).updateChildValues(["timestamp": timestamp])
            Api.MyPurchasePosts.REF_MYPURCHASE.child(self.currentUid).child((self.post?.id)!).updateChildValues(["timestamp": timestamp])
            
            self.delegate?.reloadNotification()
            
            _ = self.navigationController?.popViewController(animated: true)
        })
        
        setNotification()
        
        if let fcmToken = usermodel?.fcmToken {
            sendPushNotification(token: fcmToken)
        }
    }
}

extension PurchaseNavi2ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        //  return UITableViewAutomaticDimension
        
        switch indexPath.section {
        case 0:
            return 86
        case 1:
            return 197
        case 2:
            return 662
        case 3:
            return 249
        case 4:
            
            return 44
        case 5:
            return UITableViewAutomaticDimension
        case 6:
            return 178
        case 7:
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
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if post != nil && post != nil && address != nil && usermodel != nil {
            
            if section == 5 {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShipDeadLineNaviTableViewCell", for: indexPath) as! ShipDeadLineNaviTableViewCell
            cell.post = post
            
            return cell
        }
        
        
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseEvaluatePeopleTableViewCell", for: indexPath) as! PurchaseEvaluatePeopleTableViewCell
            cell.delegate = self
            cell.sendValueButton.isEnabled = true
            return cell
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressNaviTableViewCell", for: indexPath) as! AddressNaviTableViewCell
            cell.post = post
            cell.address = address
            return cell
        }
        
        
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TorihikiNaviTableViewCell", for: indexPath) as! TorihikiNaviTableViewCell
            
            return cell
        }
        
        if indexPath.section == 5 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatNaviTableViewCell", for: indexPath) as! ChatNaviTableViewCell
            
            cell.chat = chats[indexPath.row]
            
            if chats[indexPath.row].uid == currentUid {
                cell.usermodel = self.currentUserModel
            } else {
                cell.usermodel = self.usermodel
            }
            
            return cell
            
        }
        
        if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInputTextViewNaviTableViewCell", for: indexPath) as! MessageInputTextViewNaviTableViewCell
            cell.delegate = self
            cell.usermodel = self.usermodel
            cell.post = self.post
            return cell
        }
        
        
        
        if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YouInfoNaviTableViewCell", for: indexPath) as! YouInfoNaviTableViewCell
            cell.usermodel = usermodel
            cell.delegate = self
            cell.label1.text = "販売者情報"
            return cell
        }
        
        
        
        
        
        return UITableViewCell()
    }
    
    
}

extension PurchaseNavi2ViewController: MessageInputTextViewNaviTableViewCellDelegate, YouInfoNaviTableViewCellDelegate {
    
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

extension PurchaseNavi2ViewController : PurchaseEvaluatePeopleTableViewCellDelegate {
    func back2(valueStatus: String, valueComment: String) {
        
        showAlert(title: "評価を投稿しますか？", message: "一度投稿した評価は変更できませんのでご注意ください。", valueStatus: valueStatus, valueComment: valueComment)
        
        
    }
    
    
    
    func setNotification() {
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let newNotificationReference = Api.Notification.REF_NOTIFICATION
        let newMyNotificationReference = Api.Notification.REF_MYNOTIFICATION.child((self.post?.uid)!)
        let newNotificationId = newNotificationReference.childByAutoId().key
        
        
        newNotificationReference.child(newNotificationId!).setValue(["checked": false, "from": Api.User.CURRENT_USER!.uid, "objectId": (self.post?.id)!, "type": Config.naviEvaluatePurchaser, "timestamp": timestamp, "to": (self.post?.uid)!, "segmentType": Config.transaction])
        
        newMyNotificationReference.child(newNotificationId!).setValue(["timestamp": timestamp])
        
        
        
    }
    
    func sendPushNotification(token: String) {
        
        let indexNum = Config.pushNotiTitleCount
        guard let post = post else {return}
        var titleStr: String = post.title!
        
        if titleStr.count > indexNum {
            titleStr = String(titleStr.prefix(indexNum))
            titleStr = titleStr+"..."
        }
        let message = "「\(titleStr)」の受取通知がありました。購入者の評価を行い、取引を完了させてください。"
        
        Api.Notification.sendNotification(token: token, message: message) { (success, error) in
            if success == true {
                print("Notification sent!")
            } else {
                print("Notification sent error!")
            }
        }
    }
}
