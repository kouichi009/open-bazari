//
//  CreditCardRegisterTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

//GagetMarketのStripe決済解説Youtube動画
//https://www.youtube.com/watch?v=YGYF1OUF1TU&feature=youtu.be

import UIKit
import EMAlertController
import Stripe
import AFNetworking
import SVProgressHUD

protocol CreditCardRegisterTableViewControllerDelegate {
    func createdCard(card: Card?)
}

class CreditCardRegisterTableViewController: UITableViewController, UITextFieldDelegate {
    
    let maxNumberOfCharacters = 16
    let maxNumberOfCharacters2 = 5
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expireTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    
    
    var cardDatas = [Card]()
    var currentUid: String?
    var stripeUtil = StripeUtil()
    var cards = [AnyObject]()
    var users = [AnyObject]()
    var customerId = String()
    var purchaseVC: PurchaseViewController?
    var settingVC: SettingTableViewController?
    
    var delegate: CreditCardRegisterTableViewControllerDelegate?
    
    var uidEmail = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberTextField.delegate = self
        expireTextField.delegate = self
        cvcTextField.delegate = self
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            uidEmail = currentUid + "@gmail.com"
        }
    }
    
    func isDeletedCardAlreadyExistInFirebaseDatabase(cardLast4_DateMoji: String) -> String {
        
        var alreadyExistCardNumTex = ""
        cardDatas.forEach { (cardData) in
            
            if (cardData.id)! == cardLast4_DateMoji {
                
                alreadyExistCardNumTex = cardData.id!
            }
        }
        return alreadyExistCardNumTex
    }
    
    // Visaとマスターカードしか使えないことに注意（テスト用のクレジットカードでも同じ）
    @IBAction func register_new_creditcard() {
        
        
        print("cardNumberTextField.text \(cardNumberTextField.text?.count)")
        print("expireTextField.text \(expireTextField.text?.count)")
        print("cvc \(cvcTextField.text?.count)")
        
        if (cardNumberTextField.text?.count)! < 19 {
            showAlert(title: "無効なカード番号です。", message: "カード番号が誤っています。", validFlg: false)
            return;
        } else if (expireTextField.text?.count)! < 5 {
            showAlert(title: "期限が無効です。", message: "期限の入力が誤っています。", validFlg: false)
            
            return;
        } else if (cvcTextField.text?.count)! < 3 {
            showAlert(title: "cvcが無効です。", message: "cvcの入力が誤っています。", validFlg: false)
            return;
        }
        
        if (cardNumberTextField.text?.hasPrefix("4"))! || (cardNumberTextField.text?.hasPrefix("5"))! {
            self.showAlert(title: "カード情報を登録していいですか？", message: "", validFlg: true)
            
        } else {
            ProgressHUD.showError("使用できるカードは、VisaとMasterCardの２種類だけです。")
            print("使用できるカードは、VisaとMasterCardの２種類だけです。")
        }
        
    }
    
    func registerCreditCard() {
        SVProgressHUD.show()
        
        let cardNumTex = cardNumberTextField.text?.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        var expireNumText = expireTextField.text
        if let range = expireTextField.text?.range(of: "/") {
            expireNumText?.removeSubrange(range)
        }
        let last4Moji = "\((cardNumTex?.suffix(4))!)"
        let cardLast4_DateMoji: String = last4Moji + expireNumText!
        
        let alreadyExistCardNumTex = self.isDeletedCardAlreadyExistInFirebaseDatabase(cardLast4_DateMoji: cardLast4_DateMoji)
        if alreadyExistCardNumTex != "" && cardDatas.count > 0 {
         
            //実際にストライプ上にクレジットカードを登録してるようにみせかけるため、2秒無駄に使う（実際はfirebaseDatabaseのdeletedFlgを消してるだけ。）
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
               
               print(Thread.isMainThread)
                Api.Card.REF_CARDS.child(self.currentUid!).child(alreadyExistCardNumTex).child("deletedFlg").removeValue()
                SVProgressHUD.dismiss()
                self.popBackVC(cardLast4_DateMoji: cardLast4_DateMoji)
            }
            return;
        }
        
        let cardParams = STPCardParams()
        if expireTextField.text?.isEmpty == false {
            let expirationDate = expireTextField.text?.components(separatedBy: "/")
            let expMonth = UInt(Int(expirationDate![0])!)
            let expYear = UInt(Int(expirationDate![1])!)
            
            
            cardParams.number = cardNumberTextField.text
            cardParams.cvc = cvcTextField.text
            cardParams.expYear = expYear
            cardParams.expMonth = expMonth
        }
        //extract the card parameters given by the cardParams
        let params = cardParams
        self.stripeUtil.getUsersList(uidEmail: self.uidEmail) { (users) in
            self.users = users!
            if self.users.count > 0 {
                self.stripeUtil.customerId = self.users[0]["id"] as? String
                self.customerId = self.users[0]["id"] as! String
                self.stripeUtil.createCard(stripeId: self.stripeUtil.customerId!, card: params, completion: { (success) in
                    
                    if success == false {
                        print(Thread.current)
                        SVProgressHUD.dismiss()
                        self.showAlert(title: "無効なカードです。", message: "(エラー) カード情報の入力が誤っている可能性があります。", validFlg: false)
                        return;
                    }
                    //there is a new card !
                    self.stripeUtil.getCardsList(completion: { (result) in
                        
                        SVProgressHUD.dismiss()
                        if let result = result {
                            self.cards = result
                            
                            if Thread.isMainThread {
                                self.setFirebaseDatabase(cardLast4_DateMoji: cardLast4_DateMoji)
                                self.popBackVC(cardLast4_DateMoji: cardLast4_DateMoji)
                            } else {
                                DispatchQueue.main.async {
                                    self.setFirebaseDatabase(cardLast4_DateMoji: cardLast4_DateMoji)
                                    self.popBackVC(cardLast4_DateMoji: cardLast4_DateMoji)
                                }
                            }
                            
                        }
                        //store results on our cards, clear textfield and reload tableView
                        print(self.cards.count)
                        
                    })
                })
            } else {
                self.stripeUtil.createUser(card: params, completion: { (success) in
                    
                    if success == false {
                        SVProgressHUD.dismiss()
                        self.showAlert(title: "無効なカードです。", message: "(エラー) カード情報の入力が誤っている可能性があります。", validFlg: false)
                        return;
                    }
                    
                    
                    self.stripeUtil.getCardsList(completion: { (result) in
                        
                        SVProgressHUD.dismiss()
                        if let result = result {
                            self.cards = result
                            
                            if Thread.isMainThread {
                                self.setFirebaseDatabase(cardLast4_DateMoji: cardLast4_DateMoji)
                                self.popBackVC(cardLast4_DateMoji: cardLast4_DateMoji)
                            } else {
                                DispatchQueue.main.async {
                                    self.setFirebaseDatabase(cardLast4_DateMoji: cardLast4_DateMoji)
                                    self.popBackVC(cardLast4_DateMoji: cardLast4_DateMoji)
                                }
                            }
                        }
                        //store results on our cards, clear textfield and reload tableView
                        print(self.cards.count)
                        
                    })
                })
            }
            
        }
    }
    
    func setFirebaseDatabase(cardLast4_DateMoji: String) {
        if (cardNumberTextField.text?.hasPrefix("4"))! {
            Api.Card.REF_CARDS.child(currentUid!).child(cardLast4_DateMoji).setValue(["cardType": Config.visa])
        } else if (cardNumberTextField.text?.hasPrefix("5"))! {
            Api.Card.REF_CARDS.child(currentUid!).child(cardLast4_DateMoji).setValue(["cardType": Config.mastercard])
        }
    }
    
    
    
    func popBackVC(cardLast4_DateMoji: String) {
        
        var cardType = String()
        if (cardNumberTextField.text?.hasPrefix("4"))! {
            cardType = Config.visa
        } else if (cardNumberTextField.text?.hasPrefix("5"))! {
            cardType = Config.mastercard
        }
        
        let dict = ["cardType": cardType] as? [String: Any]
        let card = Card.transformCard(dict: dict!, key: cardLast4_DateMoji)
        
        delegate?.createdCard(card: card)
        
    
            ProgressHUD.showSuccess("クレジットカードを登録しました。")
            if let purchaseVC = purchaseVC {
                _ = self.navigationController?.popToViewController(purchaseVC, animated: true)
            }
            
            if let settingVC = settingVC {
                _ = self.navigationController?.popToViewController(settingVC, animated: true)
            }
        
    }
    
    func showAlert(title: String, message: String, validFlg: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
        })
        
        let registerOKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.registerCreditCard()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in

        })
        
        if validFlg {
            alert.addAction(registerOKAction)
            alert.addAction(cancelAction)
        } else {
            alert.addAction(OKAction)
        }
        
        // iPadでは必須！bb
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // only allow numerical characters
        
        
        if textField == cardNumberTextField {
            guard string.characters.flatMap({ Int(String($0)) }).count ==
                string.characters.count else { return false }
            
            let text = textField.text ?? ""
            
            if string.characters.count == 0 {
                textField.text = String(text.characters.dropLast()).chunkFormatted()
            }
            else {
                let newText = String((text + string).characters
                    .filter({ $0 != "-" }).prefix(maxNumberOfCharacters))
                textField.text = newText.chunkFormatted()
            }
            
            
        } else if textField == expireTextField {
            guard string.characters.flatMap({ Int(String($0)) }).count ==
                string.characters.count else { return false }
            
            let text = textField.text ?? ""
            
            if string.characters.count == 0 {
                textField.text = String(text.characters.dropLast()).chunkFormatted2()
            }
            else {
                let newText = String((text + string).characters
                    .filter({ $0 != "-" }).prefix(maxNumberOfCharacters2))
                textField.text = newText.chunkFormatted2()
            }
            
        } else if textField == cvcTextField {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 3 // Bool
        }
        return false
    }
    
    @IBAction func cvcTutorialAlert_TouchUpInside(_ sender: Any) {
        let alert = EMAlertController(icon: UIImage(named: "cvcImage"), title: "", message: "カードの裏面に記載されている3ケタの番号を入力してください。")
        
        let action2 = EMAlertAction(title: "はい", style: .normal) {
            // Perform Action
        }
        
        alert.addAction(action: action2)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension String {
    func chunkFormatted(withChunkSize chunkSize: Int = 4,
                        withSeparator separator: Character = "-") -> String {
        return characters.filter { $0 != separator }.chunk(n: chunkSize)
            .map{ String($0) }.joined(separator: String(separator))
    }
    
    func chunkFormatted2(withChunkSize chunkSize: Int = 2,
                         withSeparator separator: Character = "/") -> String {
        return characters.filter { $0 != separator }.chunk(n: chunkSize)
            .map{ String($0) }.joined(separator: String(separator))
    }
}


/* Swift 3 version of Github use oisdk:s SwiftSequence's 'chunk' method:
 https://github.com/oisdk/SwiftSequence/blob/master/Sources/ChunkWindowSplit.swift */
//https://stackoverflow.com/questions/40946134/adding-space-between-textfield-character-when-typing-in-text-filed
extension Collection {
    public func chunk(n: IndexDistance) -> [SubSequence] {
        var res: [SubSequence] = []
        var i = startIndex
        var j: Index
        while i != endIndex {
            j = index(i, offsetBy: n, limitedBy: endIndex) ?? endIndex
            res.append(self[i..<j])
            i = j
        }
        return res
    }
}

