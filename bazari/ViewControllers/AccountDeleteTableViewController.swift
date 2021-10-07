//
//  AccountDeleteTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/08.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class AccountDeleteTableViewController: UITableViewController {

    
    @IBOutlet weak var bigLbl1: UILabel!
    @IBOutlet weak var bigLbl2: UILabel!
    @IBOutlet weak var torihikiLbl: UILabel!
    @IBOutlet weak var saleExplainLbl: UILabel!
    @IBOutlet weak var finishLbl: UILabel!
    
    var currentUid = String()
    var emailTextField: UITextField?
    var passwordTextField: UITextField?
    var NONDELETESELLER = "取引中(販売側)の商品があるため、アカウント削除できません。"
    var NONDELETEBUYER = "取引中(購入側)の商品があるため、アカウント削除できません。"
    var NONDELETEPRICE = "\(Functions.formatPrice(price: Config.minimumTransferApplyPrice))円以上の売上残高があるため、アカウント削除できません。振込申請を行い、売上金を受け取ってください。"
    var errorMessage = "エラー"
    var okMessage = "OK"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Config.isUnderIphoneSE {
            bigLbl1.font = UIFont.systemFont(ofSize: 14)
            bigLbl2.font = UIFont.systemFont(ofSize: 14)
            torihikiLbl.font = UIFont.systemFont(ofSize: 10)
            saleExplainLbl.font = UIFont.systemFont(ofSize: 10)
            finishLbl.font = UIFont.systemFont(ofSize: 10)
        }
        
        saleExplainLbl.text = "\(Functions.formatPrice(price: Config.minimumTransferApplyPrice))円以上の売上残高がある場合は、退会することができません。銀行振込を行なって代金を受け取ってください。また、\(Functions.formatPrice(price: Config.minimumTransferApplyPrice))円未満の売り上げがある状態で退会された場合、その売上は無効となりますのでご注意ください。"
    }
    
    @IBAction func deleteAccount_TouchUpInside(_ sender: Any) {
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
            //取引中の商品(販売、購入両方)が一つでもあれば、アカウント削除できないようにする
            checkSellerTransaction { (isExistSellerTransaction) in
                
                if isExistSellerTransaction {
                    self.showAlert(alertTitle: self.errorMessage, alertMessage: self.NONDELETESELLER, btnTitle1: self.okMessage, btnTitle2: nil, isCancelBtn: false)
                    print(self.NONDELETESELLER)
                    SVProgressHUD.dismiss()
                    return;
                } else {
                    print("取引中（販売側）のデータなし。")
                    self.checkBuyerTransaction(completion: { (isExistBuyerTransaction) in
                        
                        if isExistBuyerTransaction {
                            self.showAlert(alertTitle: self.errorMessage, alertMessage: self.NONDELETEBUYER, btnTitle1: self.okMessage, btnTitle2: nil, isCancelBtn: false)
                            print(self.NONDELETEBUYER)
                            SVProgressHUD.dismiss()
                            return;
                        } else {
                            print("取引中（購入側）のデータなし。")
                            self.observeCharge()
                        }
                    })
                }
            }
        }
    }
    
    func checkSellerTransaction(completion: @escaping (Bool) -> Void) {
        Api.MyPosts.fetchCountMyPosts(userId: currentUid) { (myPostCount) in
            if myPostCount == 0 {
                //取引中(販売側)のデータなし
                completion(false)
            } else {
                
                var count = 0
                var isExistTransaction = false
                Api.MyPosts.observeMyAllPosts(userId: self.currentUid, completion: { (post, postCount) in
                    
                    count += 1
                    if let post = post {
                        
                        if post.transactionStatus == Config.transaction {
                            //取引中(販売側)のデータがある
                            isExistTransaction = true
                        }
                    }
                    
                    if count == postCount {
                        
                        if isExistTransaction {
                            //取引中(販売側)のデータある
                            completion(true)
                        } else {
                            //取引中(販売側)のデータなし
                            completion(false)
                        }
                    }
                })
            }
        }
    }
    
    func checkBuyerTransaction(completion: @escaping (Bool) -> Void) {
        Api.MyPurchasePosts.fetchCountMyPurchasePosts(userId: currentUid) { (myPurchasePostCount) in
            if myPurchasePostCount == 0 {
                //取引中(購入側)のデータなし
                completion(false)
            } else {
                
                var count = 0
                var isExistTransaction = false
                Api.MyPurchasePosts.observeMyAllPosts(userId: self.currentUid, completion: { (post, postCount) in
                    
                    count += 1
                    if let post = post {
                        if post.transactionStatus == Config.transaction {
                            //取引中(購入側)のデータがある
                            isExistTransaction = true
                        }
                    }
                    
                    if count == postCount {
                        
                        if isExistTransaction {
                            //取引中(購入側)のデータがある
                            completion(true)
                        } else {
                            //取引中(購入側)のデータなし
                            completion(false)
                        }
                    }
                })
            }
        }
    }
    
    func observeCharge() {
        Api.Charge.fetchChargeCount(userId: currentUid) { (chargeCount) in
            
            if chargeCount == 0 {
                self.reAuthUser()
            } else {
                var count = 0
                var totalAmount = 0
                Api.Charge.observeMyCharge(userId: self.currentUid) { (charge, chargeCount) in
                    
                    count += 1
                    if let charge = charge {
                        
                        if charge.type == Config.sold {
                            totalAmount = totalAmount + charge.price!
                        } else {
                            totalAmount = totalAmount - charge.price!
                        }
                    }
                    
                    if count == chargeCount {
                        
                        print(totalAmount)
                        
                        //売上残高が1000円以上あれば、
                        if totalAmount >= Config.minimumTransferApplyPrice {
                            self.showAlert(alertTitle: self.errorMessage, alertMessage: self.NONDELETEPRICE, btnTitle1: self.okMessage, btnTitle2: nil, isCancelBtn: false)
                            print(self.NONDELETEPRICE)
                            SVProgressHUD.dismiss()
                        } else {
                            self.reAuthUser()
                        }
                    }
                }
            }
        }
        
        
    }
    
    func deleteDatas() {
        Api.MyPosts.REF_MYPOSTS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            let arraySnapshot = snapshot.children.allObjects as? [DataSnapshot]
            arraySnapshot?.forEach({ (child) in
                let postId = child.key
                Api.Post.REF_POSTS.child(postId).updateChildValues(["isCancel": true])
            })
        }
        
        Api.Card.observeCard(withId: currentUid) { (card, cardCount) in
            
            if let card = card {
                Api.Card.REF_CARDS.child(self.currentUid).child(card.id!).updateChildValues(["deletedFlg": true])
            }
        }
        
        Api.Comment.cancelMyComments(currentUid: currentUid)
        
        Api.User.REF_USERS.child(currentUid).updateChildValues(["isCancel": true])
        
        deleteFollow()
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            
            Api.User.CURRENT_USER?.delete(completion: { (error) in
                
                if error != nil {
                    print("notdeleteAuth ", error?.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                
                print("deleteSuccessed ", Api.User.CURRENT_USER?.uid)
                ProgressHUD.showSuccess("アカウント削除しました")
                print("アカウント削除しました")
                SVProgressHUD.dismiss()
                //データーベースは削除できたが、Authenticationが削除できなかったとき、ユーザーログアウトを行う
                
                do {
                    try Auth.auth().signOut()
                    
                    
                } catch let logoutError {
                    print(logoutError.localizedDescription)
                }
                
                if Auth.auth().currentUser == nil {
                    print("Auth消した")
                }
                
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                }
                
                
                var storyboard = UIStoryboard()
                storyboard = UIStoryboard(name: "Main", bundle: nil)
                let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
                self.present(registerVC, animated: true, completion: nil)
                
                
            })
        }
    }
    
    func deleteFollow() {
        var count = 0
        Api.Follow.observeDeleteFollow(userId: self.currentUid, completion: { (resultUid, followCount) in
            
            if followCount == 0 {
                self.deleteFollower()
                return;
            }
            
            count += 1
            Api.Follow.REF_FOLLOWING.child(self.currentUid).child(resultUid).setValue(NSNull())
            Api.Follow.REF_FOLLOWING.child(resultUid).child(self.currentUid).setValue(NSNull())
            Api.Follow.REF_FOLLOWERS.child(self.currentUid).child(resultUid).setValue(NSNull())
            Api.Follow.REF_FOLLOWERS.child(resultUid).child(self.currentUid).setValue(NSNull())
            
            if count == followCount {
                self.deleteFollower()
            }
        })
    }
    
    func deleteFollower() {
        var count = 0
        Api.Follow.observeDeleteFollower(userId: self.currentUid, completion: { (resultUid, followerCount) in
            
            if followerCount == 0 {
                // self.deleteFollower()
                print("none")
                return;
            }
            
            count += 1
            Api.Follow.REF_FOLLOWING.child(self.currentUid).child(resultUid).setValue(NSNull())
            Api.Follow.REF_FOLLOWING.child(resultUid).child(self.currentUid).setValue(NSNull())
            Api.Follow.REF_FOLLOWERS.child(self.currentUid).child(resultUid).setValue(NSNull())
            Api.Follow.REF_FOLLOWERS.child(resultUid).child(self.currentUid).setValue(NSNull())
            
            if count == followerCount {
                
                print("deletefollower")
            }
        })
    }
    
    func reAuthUser() {
        Api.User.observeUser(withId: currentUid) { (usermodel) in
            
            SVProgressHUD.dismiss()
            if usermodel?.loginType == Config.LoginTypeEmail {
                //email
                self.addTextFieldInUIAlertcontroller()
                
            } else if usermodel?.loginType == Config.LoginTypeFacebook {
                
                if let _ = usermodel?.isEmailAuth {
                    //email or facebook
                    self.showAlert(alertTitle: "再ログイン＆アカウント削除", alertMessage: "アカウント削除するには、再ログインする必要があります。", btnTitle1: "Facebookで再ログイン&アカウント削除", btnTitle2: "メールアドレスで再ログイン&アカウント削除", isCancelBtn: true)
                } else {
                    // facebook
                    self.showAlert(alertTitle: "再ログイン＆アカウント削除", alertMessage: "アカウント削除するには、再ログインする必要があります。", btnTitle1: "Facebookで再ログイン&アカウント削除", btnTitle2: nil, isCancelBtn: true)
                }
            }
        }
    }
    
    
    func showAlert(alertTitle: String?, alertMessage: String?, btnTitle1: String?, btnTitle2: String?, isCancelBtn: Bool) {
        
        
        let alert = UIAlertController(title: alertTitle!, message: alertMessage!, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        var firstBtnAction: UIAlertAction?
        if let btnTitle1 = btnTitle1 {
            firstBtnAction = UIAlertAction(title: btnTitle1, style: .default, handler: {(alert: UIAlertAction!) in
                
                if btnTitle1 != self.okMessage {
                    //Facebookログイン
                    self.facebookLogin()
                }
            })
        }
        
        var secondBtnAction: UIAlertAction?
        if let btnTitle2 = btnTitle2 {
            secondBtnAction = UIAlertAction(title: btnTitle2, style: .default, handler: {(alert: UIAlertAction!) in
                //Emailログイン
                self.addTextFieldInUIAlertcontroller()
            })
        }
        
        if !isCancelBtn {
            alert.addAction(firstBtnAction!)
        } else {
            alert.addAction(firstBtnAction!)
            
            if let secondBtnAction = secondBtnAction {
                alert.addAction(secondBtnAction)
            }
            alert.addAction(cancelAction)
            
        }
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func facebookLogin() {
        let credential = FacebookAuthProvider.credential(withAccessToken:  FBSDKAccessToken.current().tokenString)
        Api.User.CURRENT_USER?.reauthenticate(with: credential, completion: { (error) in
            if error != nil {
                print("errrorMesssage ", (error?.localizedDescription)!)
                var errorMessage = error?.localizedDescription
                ProgressHUD.showError("削除失敗しました")
                return;
            } else {
                print("Success reAuthenticationByEmail!!!")
                SVProgressHUD.show()
                self.deleteDatas()
            }
        })
    }
    
    func addTextFieldInUIAlertcontroller() {
        let alertController = UIAlertController(title: "アカウント削除", message: "メールアドレスとパスワードを入力してください。", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: emailTextField)
        alertController.addTextField(configurationHandler: passwordTextField)
        
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            
            guard let emailTex = self.emailTextField?.text else {return}
            guard let passwordTex = self.passwordTextField?.text else {return}
            
            SVProgressHUD.show()
            
            let credential = EmailAuthProvider.credential(withEmail: emailTex, password: passwordTex)
            Api.User.CURRENT_USER?.reauthenticate(with: credential, completion: { (error) in
                if error != nil {
                    print("errrorMesssage ", (error?.localizedDescription)!)
                    var errorMessage = error?.localizedDescription
                    if (errorMessage?.contains("badly formatted"))! {
                        errorMessage = "メールアドレスの形式が不正です。"
                    }
                        
                    else {
                        errorMessage = "メールアドレスとパスワードが一致しません。"
                    }
                    ProgressHUD.showError(errorMessage)
                    SVProgressHUD.dismiss()
                } else {
                    print("Success reAuthenticationByEmail!!!")
                    self.deleteDatas()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func emailTextField(textField: UITextField!) {
        emailTextField = textField
        emailTextField?.placeholder = "メールアドレス"
    }
    
    func passwordTextField(textField: UITextField!) {
        passwordTextField = textField
        passwordTextField?.placeholder = "パスワード"
    }
    
}
