//
//  PurchaseViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/25.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

protocol PurchaseViewControllerDelegate {
    func changePurchaseButton()
}

class PurchaseViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var postId: String = String()
    var post: Post?
    var address: Address?
    var currentUid = String()
    var usermodel: UserModel?
    
    var cards = [AnyObject]()
    var cardIds = [String]()
    var users = [AnyObject]()
    var stripeUtil = StripeUtil()
    var last4NumFromStripeStrs = [String]()
    var customerId = String()
    var selectedCard: Card?
    var selectedCardId: String?
    
    var delegate: PurchaseViewControllerDelegate?
    
    var uidEmail = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            uidEmail = currentUid + "@gmail.com"
        }
        
        var count = 0
        Api.Card.observeCard(withId: currentUid) { (card, cardCount) in
            
            if cardCount == 0 {
                print("クレジットカード未登録")
                self.load()
            } else {
                
                count += 1
                
                if let card = card {
                    
                    if card.deletedFlg == nil {
                        self.selectedCard = card
                    }
                }
                
                if count == cardCount {
                    self.fetchCardFromStripe(uidEmail: self.uidEmail)
                }
                
            }
        }
        
        
    }
    
    
    func load() {
        
        Api.Post.observePost(postId: postId) { (post) in
            
            if let post = post {
                self.post = post
                self.title = post.title
                
                if let postUid = post.uid {
                    Api.User.observeUser(withId: postUid, completion: { (usermodel) in
                        self.usermodel = usermodel
                    })
                }
                
                self.tableView.reloadData()
            }
        }
        Api.Address.observeAddress(userId: currentUid) { (address) in
            
            if let address = address {
                self.address = address
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func sendPushNotification(token: String) {
        
        let indexNum = Config.pushNotiTitleCount
        var titleStr: String = post!.title!
        
        if titleStr.count > indexNum {
            titleStr = String(titleStr.prefix(indexNum))
            titleStr = titleStr+"..."
        }
        let message = "「\(titleStr)」の商品代金が支払われました。商品を発送してください。"
        
        Api.Notification.sendNotification(token: token, message: message) { (success, error) in
            if success == true {
                print("Notification sent!")
            } else {
                print("Notification sent error!")
            }
        }
    }
    
    func fetchCardFromStripe(uidEmail: String) {
        //check if the customerId exist
        self.stripeUtil.getUsersList(uidEmail: uidEmail) { (users) in
            self.users = users!
            if self.users.count > 0 {
                self.stripeUtil.customerId = self.users[0]["id"] as? String
                self.customerId = self.users[0]["id"] as! String
                self.stripeUtil.getCardsList(completion: { (result) in
                    if let result = result {
                        self.cards = result
                        for i in 0..<self.cards.count {
                            let cardId = self.cards[i]["id"] as! String
                            //print(cardId as! String)
                            print("cardId \(cardId)")
                            print("type :\(type(of: cardId))")
                            print(i)
                            print(self.cards.count)
                            self.cardIds.append(cardId)
                            self.getCardLast4NumberFromStripe(i: i, cardId: cardId)
                        }
                        
                        //forループ抜けた
                        self.load() //load functionの中でtableView.reloadDataがある。
                        
                        if self.selectedCardId == nil {
                            print("Stripe上にクレカ情報はあるけど、全て削除済みで現在使えるカードは一枚もない。")
                            print("クレジットカード未登録")
                            
                        } else {
                            print("使えるカードあり")
                            print("self.selectedCardId \(self.selectedCardId!)")
                            
                        }
                    }
                    
                })
            }
            
        }
    }
    
    func getCardLast4NumberFromStripe(i: Int, cardId: String) {
        
        let last4: String = self.cards[i]["last4"] as! String
        let month: Int = self.cards[i]["exp_month"] as! Int
        let year: Int = self.cards[i]["exp_year"] as! Int
        
        var expirationMonth = String(month)
        var expirationYear = String(year)
        
        print(type(of: expirationMonth))
        print(type(of: expirationYear))
        
        
        print("last4 \(last4)")
        print("expirationMonth \(expirationMonth)")
        print("expirationYear \(expirationYear)")
        print("i \(i)")
        
        if expirationMonth.count < 2 {
            expirationMonth = "0" + expirationMonth
        }
        
        if expirationYear.count > 2 {
            expirationYear = String(expirationYear.suffix(2))
        }
        
        let last4Num_Dates = last4 + expirationMonth + expirationYear
        print("last4Num_Dates \(last4Num_Dates)")
        self.last4NumFromStripeStrs.append(last4Num_Dates)
        
        if let card = selectedCard {
            if card.id == last4Num_Dates {
                self.selectedCardId = cardId
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayAdd_Seg" {
            let displayVC = segue.destination as! Display_AddViewController
            displayVC.purchaseVC = self
            displayVC.delegate = self
        }
    }
    
}

extension PurchaseViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 86
        case 1:
            return 165
        case 2:
            return 209
        default:
            print("t")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if post != nil && address != nil {
            return 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
            cell.selectedCard = self.selectedCard
            cell.post = post
            cell.delegate = self
            cell.paymentBtn.isEnabled = true
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressNaviTableViewCell", for: indexPath) as! AddressNaviTableViewCell
            cell.post = post
            cell.address = address
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}

extension PurchaseViewController: PaymentTableViewCellDelegate {
    
    func payButtonTouch() {
        
        guard let _ = self.selectedCard else {
            //PaymentTableViewCellのpaymentBtn.isEnabled = true にして、再び購入ボタンをおすことができるようにするため。
            self.tableView.reloadData()
            self.performSegue(withIdentifier: "displayAdd_Seg", sender: nil)
            ProgressHUD.showError("クレジットカードが未登録です。")
            return}
        
        if customerId == "" {
            //PaymentTableViewCellのpaymentBtn.isEnabled = true にして、再び購入ボタンをおすことができるようにするため。
            self.tableView.reloadData()
            return;
        }
        
        self.showAlert(title: "このまま購入してよろしいですか？", message: "", isBackToViewFlg: false) { (success) in
            
            if success == true {
                self.postToStripe()
            } else {
                //PaymentTableViewCellのpaymentBtn.isEnabled = true にして、再び購入ボタンをおすことができるようにするため。
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func postToStripe() {
        SVProgressHUD.show()
        
        var price = post?.price
        price = price! / 100
        
        // url to your server
        let url = "\(Config.herokuForStripeServerUrl)/payment.php"
        let params: [String : Any] = [
            "stripeToken" : self.selectedCardId!,
            "amount" : price!,
            "currency" : "jpy",
            "description" : self.selectedCardId!,
            "customerId": self.customerId
        ]
        
        let manager = AFHTTPSessionManager().post(url, parameters: params, success: { (operation, responseObject) in
            if let response = responseObject as? [String: String] {
                print(response["status"]! + "________" + response["message"]!)
                
                self.purchase()
            }
            
        }) { (operation, error) in
            if error != nil {
                print("errorMessage \(error.localizedDescription)")
                ProgressHUD.showError(error.localizedDescription)
                SVProgressHUD.dismiss()
                return;
            }
        }
    }
    
    
    func purchase() {
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
        
        Api.MyPurchasePosts.REF_MYPURCHASE.child(currentUid).child((self.post?.id)!).setValue(["timestamp": timestamp])
        Api.Post.REF_POSTS.child((post?.id)!).updateChildValues(["commisionRate": Config.commisionRate, "transactionStatus": Config.transaction, "purchaserUid": currentUid, "purchaseDateTimestamp": timestamp, Config.purchaserShouldDo: Config.waitForShip, Config.sellerShouldDo: Config.ship]) { (error, ref) in
           SVProgressHUD.dismiss()
            
           
            Api.MySellPosts.REF_MYSELL.child((self.post?.uid)!).child((self.post?.id)!).updateChildValues(["timestamp": timestamp])
            
            self.delegate?.changePurchaseButton()
            if let fcmToken = self.usermodel?.fcmToken {
                self.sendPushNotification(token: fcmToken)
            }
            
            self.showAlert(title: "商品の購入、支払いが完了しました。", message: "出品者が商品を発送したら通知にてお知らせします", isBackToViewFlg: true, completion: { (success) in
                
            })
        }
        
        setNotifications(timestamp: timestamp, currentUid: currentUid, post: post!)
        
    }
    
    func setNotifications(timestamp: Int, currentUid: String, post: Post) {
        let newNotificationReference = Api.Notification.REF_NOTIFICATION
        let newMyNotificationReference = Api.Notification.REF_MYNOTIFICATION.child(post.uid!)
        let newNotificationId = newNotificationReference.childByAutoId().key
        
        newNotificationReference.child(newNotificationId!).setValue(["checked": false, "from": currentUid, "objectId": post.id!, "type": Config.naviPurchase, "timestamp": timestamp, "to": post.uid!, "segmentType": Config.transaction])
        newMyNotificationReference.child(newNotificationId!).setValue(["timestamp": timestamp])
        
    }
    
    
    func goToAddCardVC() {
        self.performSegue(withIdentifier: "displayAdd_Seg", sender: nil)
    }
    
    func showAlert(title: String, message: String, isBackToViewFlg: Bool, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        
        let onlyOKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            completion(true)
            _ = self.navigationController?.popViewController(animated: true)
        })
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            completion(true)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            completion(false)
        })
        
        if isBackToViewFlg {
            alert.addAction(onlyOKAction)
        } else {
            alert.addAction(OKAction)
            alert.addAction(cancelAction)

        }
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
extension PurchaseViewController: CreditCardRegisterTableViewControllerDelegate {
    func createdCard(card: Card?) {
        self.selectedCard = card
        self.fetchCardFromStripe(uidEmail: self.uidEmail)
    }
}

