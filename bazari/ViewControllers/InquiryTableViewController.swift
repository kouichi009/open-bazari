//
//  InquiryTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import MessageUI
import Toaster

class InquiryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var inquiryTextField: UITextField!
    
    var pickerView: UIPickerView = UIPickerView()
    let list = ["", "アプリの不具合", "機能の要望", "その他"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTap))
   //     let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(b))
        toolbar.setItems([doneItem], animated: true)
        
        self.inquiryTextField.inputView = pickerView
        self.inquiryTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneTap() {
        self.inquiryTextField.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.inquiryTextField.text = list[row]
    }
    
    func cancel() {
        self.inquiryTextField.text = ""
        self.inquiryTextField.endEditing(true)
    }
    
    func done() {
        self.inquiryTextField.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func inquiry_TouchUpInside(_ sender: Any) {
        
        if inquiryTextField.text == "" {
            ProgressHUD.showError("問い合わせ内容を入力してください。")
        } else {
            sendEmail()
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["appruby1192@gmail.com"])
            //            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            let infoDictionary = Bundle.main.infoDictionary!
            // アプリバージョン情報
            let version = infoDictionary["CFBundleShortVersionString"]! as! String
            
            // ビルドバージョン情報
            //          let build = infoDictionary["CFBundleVersion"]! as! String
            
            print("version ",version)
            //       print("build ",build)
            //     print("name ",UIDevice.current.name)
            //OS名
            let systemName = UIDevice.current.systemName
            print("systemName ",UIDevice.current.systemName)
            
            //OSバージョン
            let systemVersion = UIDevice.current.systemVersion
            print("systemVersion ",UIDevice.current.systemVersion)
            
            //OSのモデル名
            print("model ",UIDevice.current.model)
            //日付取得
            let now = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //     print(formatter.string(from: now as Date))
            
            var str = String()
            if inquiryTextField.text == "アプリの不具合" {
                mail.setSubject(inquiryTextField.text!)
                str = "不具合の詳細をご記入ください。<br>スクリーンショットがありますと、とても参考になります。"
            }
            if inquiryTextField.text == "機能の要望" {
                mail.setSubject(inquiryTextField.text!)
                str = "ご連絡いただいた内容は、今後の改善の参考にさせていただきます。<br>恐れ入りますが、個別の返信は行っておりません。何卒ご了承ください。"
            } else {
                mail.setSubject("その他お問い合わせ")
                str = "お困りの内容をご記入ください。"
            }
            mail.setMessageBody("\(str)<br><br><br><p>-------以下の内容はそのままで--------</p><p>\(systemName) \(systemVersion)</p><p>アプリVer: \(version)</p><p>日付: \(formatter.string(from: now as Date))</p><p>アプリ名: \(Config.appName)</p>", isHTML: true)
            
            
            present(mail, animated: true)
        } else {
            print("メーラー インストールされていない")
            
            let alert = UIAlertController(title: "'メール'を復元しますか？", message: "App”メール”を選択しましたが、このAppはもうiPhoneにインストールされていません。App Storeから復元できます。", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            let OKAction = UIAlertAction(title: "App Storeで表示", style: .default, handler: {(alert: UIAlertAction!) in
                
                let itunesURL:String = Config.mailToUrl
                UIApplication.shared.open(URL(string: itunesURL)!, options: [:], completionHandler: nil)
                
            })
            
            alert.addAction(cancelAction)
            alert.addAction(OKAction)
            alert.preferredAction = OKAction
            
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            ToastView.appearance().cornerRadius = 10
            ToastView.appearance().backgroundColor = .gray
            ToastView.appearance().bottomOffsetPortrait = 100
            ToastView.appearance().font = .systemFont(ofSize: 16)
            Toast(text: "問い合わせメールを送信しました。").show()
        default:
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
    
}
