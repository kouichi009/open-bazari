//
//  VerifyPhoneViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/09.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import DigitInputView
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import Repro.RPREventProperties

class VerifyPhoneViewController: UIViewController {

    var digitInput: DigitInputView!
    var label1: UILabel!
    var label2: UILabel!
    var button1: UIButton!
    var button2: UIButton!
    var phoneNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLabel1()
        createLabel2()
        createDigitInput()
        createButton1()
      //  createButton2()
        // Let editing end when the view is tapped
        _ = digitInput.becomeFirstResponder()
        
        
        let defaults = UserDefaults.standard
        print("authDefalts ", defaults.string(forKey: "authVID")!)
        
        
    }
    
    func reproAnalyticsSuccessSMS() {
        
        // Custom event
        Repro.track("SMS認証成功", properties:nil)
    }
    
    
    func reproAnalyticsSkip() {
        
        //ここが走るということは、SMS認証コードは送信済みにも関わらず、スキップしたので、
        //SMS認証がうまく作動していない可能性が高い。（音声による認証も実装必要か）
        // Custom event
        Repro.track("SMS認証スキップ2(SMS認証送信済み)", properties:nil)
    }
    
    func createDigitInput() {
        digitInput = DigitInputView()
        view.addSubview(digitInput)
        digitInput.numberOfDigits = 6
        digitInput.bottomBorderColor = .purple
        digitInput.nextDigitBottomBorderColor = .red
        digitInput.textColor = .purple
        digitInput.acceptableCharacters = "0123456789"
        digitInput.keyboardType = .decimalPad
        digitInput.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: UIFont.Weight(rawValue: 1))
        digitInput.animationType = .spring
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        layoutDigitInput()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        let tap2 = UITapGestureRecognizer(target: self, action: #selector(editing(_:)))
    //        digitInput.addGestureRecognizer(tap2)
    //
    //    }
    
    func layoutDigitInput() {
        // if you wanna use layout constraints
        digitInput.translatesAutoresizingMaskIntoConstraints = false
        digitInput.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 20).isActive = true
        digitInput.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        digitInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        digitInput.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        
    }
    
    func createButton1() {
        button1 = UIButton(type: .system)
        button1.backgroundColor = UIColor.black
        button1.titleLabel?.textColor = UIColor.white
        button1.tintColor = UIColor.white
        button1.layer.cornerRadius = 15.0
        button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button1.setTitle("次へ", for: UIControlState.normal)
        button1.addTarget(self, action: #selector(nextBtn_Pressed), for: UIControlEvents.touchUpInside)
        view.addSubview(button1)
        layoutButton1()
    }
    
    func layoutButton1() {
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.topAnchor.constraint(equalTo: digitInput.bottomAnchor, constant: 50).isActive = true
        button1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        button1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        button1.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    @objc func nextBtn_Pressed() {
        print(digitInput.text)
        print(digitInput.numberOfDigits)
        print(digitInput.text.count)
        ProgressHUD.show("コードを認証中です。")
        if digitInput.numberOfDigits == digitInput.text.count {
            let defaults = UserDefaults.standard
            let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: /*codeTextField.text!*/digitInput.text)
            
            if let _ = Api.User.CURRENT_USER?.uid {
                Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (result, error) in
                    
                    if error != nil {
                        ProgressHUD.showError("コードが一致しません。")
                        print("errorMessage \(error?.localizedDescription)")
                    } else {
                        print("userId Success!! \(result?.user.uid)")
                        let uid = result?.user.uid
                        ProgressHUD.showSuccess("認証完了")
                        self.reproAnalyticsSuccessSMS()
                        Api.Address.REF_ADDRESS.child(uid!).updateChildValues(["phoneNumber": self.phoneNumber])
                        Api.User.REF_USERS.child(uid!).updateChildValues(["isPhoneAuth": true])
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
                        self.present(registerVC, animated: true, completion: nil)

                    }
                })
                
            }
            
        } else {
            ProgressHUD.showError("コードは6ケタです。")
        }
    }
    
//    func createButton2() {
//        button2 = UIButton(type: .system)
//        //    button1.backgroundColor = UIColor.black
//        //        button1.titleLabel?.textColor = UIColor.white
//        button2.tintColor = UIColor.blue
//        //      button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
//        button2.setTitle("コードが届かなかった場合", for: UIControlState.normal)
//        button2.addTarget(self, action: #selector(self.goToResendSMS), for: UIControlEvents.touchUpInside)
//        view.addSubview(button2)
//        layoutButton2()
//    }
    
    @objc func goToResendSMS() {
        
        facebookLogin_Touch()
        //   self.performSegue(withIdentifier: "ResendSMS_Seg", sender: nil)
    }
    
    func facebookLogin_Touch() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            
            
            if (error != nil){
                
                print("FB Login failed: ", error)
                ProgressHUD.showError("ログイン失敗")
                return
            }
            
            if let result1 = result {
                if result?.isCancelled == true {
                    ProgressHUD.showError("ログインに失敗しました")
                    return;
                }
            }
            
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else {return}
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signIn(with: credentials) { (user, error) in
                self.facebookToEmailLink()
            }
        }
    }
    
    func facebookToEmailLink() {
        
        let userdefaults = UserDefaults.standard
        let testCount = userdefaults.integer(forKey: "testcounting")
        userdefaults.set(testCount + 1, forKey: "testcounting")
        let credential = EmailAuthProvider.credential(withEmail: "useruseruser\(testCount)@gmail.com", password: "123456")
        
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (result, error) in
            if error != nil {
                var errorMessage = error!.localizedDescription
                
                print("errorMessage \(errorMessage)")
                errorMessage = "エラーが発生しました"
                
                if (errorMessage.contains("badly formatted")) {
                    errorMessage = "メールアドレスの形式が不正です。"
                }
                
                
                if (errorMessage.contains("6 characters")) {
                    errorMessage = "パスワードは６文字以上にしてください。"
                }
                
                ProgressHUD.showError(errorMessage)
                
            } else {
                
                ProgressHUD.showSuccess("Emailログインしました。")
                //                let uid = result?.user.uid
                //                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid!)
                //                print(uid!)
                //                print("storageRef ", storageRef)
                //
                //
                //                storageRef.putData(self.imageData!, metadata: nil, completion: { (metadata, error) in
                //
                //
                //                    storageRef.downloadURL(completion: { (url, error) in
                //                        print("url \(url)")
                //                        if let profileImageUrl = url {
                //
                //                            let uid = result?.user.uid
                //                            print("uid \(uid)")
                //
                //                            let timestamp = Int(Date().timeIntervalSince1970)
                //                            Api.User.REF_USERS.child(uid!).updateChildValues(["loginType": Config.LoginTypeEmail, "timestamp": timestamp, "email": self.emailTextField.text!, "username": self.emailTextField.text!, "username_lowercase": self.emailTextField.text!, "profileImageUrl": profileImageUrl.absoluteString], withCompletionBlock: { (error, ref) in
                //
                //                                print("e-mailログインしました。")
                //                                //   self.goToMainVC()
                //                            })
                //
                //                        }
                //                    })
                //
                //                })
                
                
                
            }
        })
    }
    
    
    func layoutButton2() {
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 20).isActive = true
        button2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        button2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        //        button2.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    func createLabel1() {
        label1 = UILabel()
        label1.tintColor = UIColor.gray
        label1.font = UIFont.systemFont(ofSize: 12)
        //        if let phoneNumber = HelperService.phoneNumber {
        //            label1.text = "TEL: \(phoneNumber)"
        //        }
        label1.textColor = UIColor.gray
        label1.textAlignment = .center
        self.view.addSubview(label1)
        layoutLabel1()
    }
    
    func layoutLabel1() {
        label1.translatesAutoresizingMaskIntoConstraints = false
        //50 + 20の20は、UINavavigationBarの高さ分
        label1.topAnchor.constraint(equalTo: view.topAnchor, constant: (50 + 20)).isActive = true
        label1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        label1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        //        label1.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    func createLabel2() {
        label2 = UILabel()
        label2.tintColor = UIColor.gray
        
        label2.text = "コードを入力してください。"
        label2.textColor = UIColor.gray
        label2.textAlignment = .center
        self.view.addSubview(label2)
        layoutLabel2()
    }
    
    func layoutLabel2() {
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10).isActive = true
        label2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        label2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        //       label2.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func endEditing(_ sender: UITapGestureRecognizer) {
        print("test")
        _ = digitInput.resignFirstResponder()
        print(digitInput.text)
    }
    
    @IBAction func skipVerify(_ sender: Any) {
        
        //ここが走るということは、SMS認証コードは送信済みにも関わらず、スキップしたので、
        //SMS認証がうまく作動していない可能性が高い。（音声による認証も実装必要か）
        self.reproAnalyticsSkip()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
        self.present(registerVC, animated: true, completion: nil)
    }
    
    
    //    @objc func editing(_ sender: UITapGestureRecognizer) {
    //        print("test")
    ////        _ = digitInput.resignFirstResponder()
    //        print(digitInput.text)
    //    }
    //
    //    func focusDigitInput() {
    //        digitInput.text.count =>
    //   }
    
}
