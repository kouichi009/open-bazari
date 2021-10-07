//
//  Display_AddViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/30.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

//GagetMarketのStripe決済解説Youtube動画
//https://www.youtube.com/watch?v=YGYF1OUF1TU&feature=youtu.be

import UIKit
import SVProgressHUD

class Display_AddViewController: UIViewController {

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var optionBtn: UIBarButtonItem!
    
    let originalGreenColor = UIColor(red: 111/255, green: 193/255, blue: 165/255, alpha: 1)
    
    var stripeUtil = StripeUtil()
    var users = [AnyObject]()
    var cards = [AnyObject]()
    var cardIds = [String]()
    var currentUid: String?
    var cardDatas = [Card]()
    var selectedCardData: Card?
    
    var purchaseVC: PurchaseViewController?
    var settingVC: SettingTableViewController?
    var delegate: CreditCardRegisterTableViewControllerDelegate?
    
    var registerCreditCardMoji = "クレジットカードを登録する"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUid = Api.User.CURRENT_USER?.uid
        leftImageView.isHidden = true
        label.isHidden = true
        nextImageView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.delete_Tap))
        leftImageView.addGestureRecognizer(tapGesture)
        leftImageView.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.goToCardRegister))
        uiView.addGestureRecognizer(tapGesture2)
        uiView.isUserInteractionEnabled = true
        isExistActiveCard()
    }
    
    
    func isExistActiveCard() {
        
        var count = 0
        Api.Card.observeCard(withId: currentUid!) { (card, cardCount) in
            
            if cardCount == 0 {
                self.setCreditCardAddForm()
                return;
            }
            
            count += 1
            if let card = card {
                self.cardDatas.append(card)
                //deletedFlgがnilつまり、trueでない場合なので、削除されてない使えるクレジットカードをselectedCardDataに入れる。
                if card.deletedFlg == nil {
                    self.selectedCardData = card
                }
            }
            
            if count == cardCount {
                // 使えるカードが一枚もない場合、
                if self.selectedCardData == nil {
                    self.setCreditCardAddForm()
                } else {
                    self.setCreditCard()
                }
            }
        }
    }
    
    @objc func goToCardRegister() {
        
        if label.text == registerCreditCardMoji {
            self.performSegue(withIdentifier: "RegisterCard_Seg", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterCard_Seg" {
            let creditRegVC = segue.destination as! CreditCardRegisterTableViewController
            creditRegVC.cardDatas = cardDatas
            creditRegVC.purchaseVC = purchaseVC
            creditRegVC.delegate = purchaseVC
            creditRegVC.settingVC = settingVC
        }
    }
    
    
    func setCreditCardAddForm() {
      
        leftImageView.isHidden = false
        label.isHidden = false
        nextImageView.isHidden = false
        
        let btnImage = UIImage(named: "addPhoto")?.withRenderingMode(.alwaysTemplate)
        leftImageView.image = btnImage
        leftImageView.tintColor = originalGreenColor
        label.text = registerCreditCardMoji
        label.textColor = originalGreenColor
    }
   
    func setCreditCard() {
        var btnImage: UIImage?
        if selectedCardData?.cardType == Config.visa {
            btnImage = UIImage(named: "visa")?.withRenderingMode(.alwaysOriginal)
        } else if selectedCardData?.cardType == Config.mastercard {
            btnImage = UIImage(named: "master")?.withRenderingMode(.alwaysOriginal)
        }
        leftImageView.image = btnImage!
//        leftImageView.tintColor = UIColor.red
        let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
        nextImageView.image = image
        nextImageView.tintColor = originalGreenColor
        leftImageView.isHidden = false
        label.isHidden = false
        nextImageView.isHidden = false
        
        //カードデータは1枚しか使えないようにしている仕様
        let eightMoji: String = String((selectedCardData?.id)!)
        let start4Moji = eightMoji.prefix(4)
        let last4Moji = eightMoji.suffix(4)
        let laststart2Moji = last4Moji.prefix(2)
        let lastlast2Moji = last4Moji.suffix(2)
        
        let zenhan = "************ " + start4Moji + "  "
        let kouhan = laststart2Moji + "/" + lastlast2Moji + ""
        let cardInfoMoji = zenhan + kouhan
        
        label.text = cardInfoMoji
        label.textColor = UIColor.black
    }
    
    @IBAction func optionBtn_TouchUpInside(_ sender: Any) {
        if let _ = selectedCardData {
            if optionBtn.title == "完了" {
                var btnImage: UIImage?
                if selectedCardData?.cardType == Config.visa {
                    btnImage = UIImage(named: "visa")?.withRenderingMode(.alwaysOriginal)
                } else if selectedCardData?.cardType == Config.mastercard {
                    btnImage = UIImage(named: "master")?.withRenderingMode(.alwaysOriginal)
                }
                leftImageView.image = btnImage
                nextImageView.image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
                nextImageView.tintColor = originalGreenColor
                nextImageView.isHidden = false
                optionBtn.title = "編集"
            } else {
                let btnImage = UIImage(named: "smallRedDelete")?.withRenderingMode(.alwaysOriginal)
                leftImageView.image = btnImage
                nextImageView.isHidden = true
                optionBtn.title = "完了"

            }
        }
    }
    
    @objc func delete_Tap() {
        if optionBtn.title == "完了" {
            
            let alert = UIAlertController(title: "クレジットカード情報の消去", message: "カード情報を消去してよろしいですか？", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
            let OKAction = UIAlertAction(title: "はい", style: .default, handler: {(alert: UIAlertAction!) in
                
                SVProgressHUD.show()
                Api.Card.REF_CARDS.child(self.currentUid!).child((self.selectedCardData?.id)!).updateChildValues(["deletedFlg": true], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        ProgressHUD.showError("エラー発生")
                        SVProgressHUD.dismiss()
                        return;
                    } else {
                        //PurchaseViewControllerにカード情報（nil）を渡す
                        self.delegate?.createdCard(card: nil)
                        
                        //実際にストライプ上からクレジットカードを削除してるようにみせかけるため、2秒無駄に使う
                        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (timer) in
                            SVProgressHUD.showSuccess(withStatus: "カード情報を削除しました。")
                            _ = self.navigationController?.popViewController(animated: true)

                        })
                    }
                    
                })
                
            })
            alert.addAction(cancelAction)
            alert.addAction(OKAction)
            
            // iPadでは必須！bb
            alert.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            // ここで表示位置を調整
            // xは画面中央、yは画面下部になる様に指定
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
        
        if label.text == registerCreditCardMoji {
            self.performSegue(withIdentifier: "RegisterCard_Seg", sender: nil)
        }
    }
    
}

