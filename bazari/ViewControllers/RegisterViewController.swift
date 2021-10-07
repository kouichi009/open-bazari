//
//  RegisterViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import Toaster
import SVProgressHUD
import Repro.RPREventProperties

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var facebookLoginView: UIView!
    @IBOutlet weak var emailRegisterView: UIView!
    @IBOutlet weak var emailLoginView: UIView!
    @IBOutlet weak var otherPhoneLoginView: UIView!
    @IBOutlet weak var facebookIconImageView: UIImageView!
    
    @IBOutlet weak var fbLbl: UILabel!
    @IBOutlet weak var emailRegisterLbl: UILabel!
    @IBOutlet weak var emailLoginLbl: UILabel!
    @IBOutlet weak var emailKishuhenLbl: UILabel!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Config.isUnderIphoneSE {
            fbLbl.font = UIFont.boldSystemFont(ofSize: 12.0)
            
            emailRegisterLbl.font = UIFont.boldSystemFont(ofSize: 12.0)
            emailLoginLbl.font = UIFont.boldSystemFont(ofSize: 12.0)
            emailKishuhenLbl.font = UIFont.boldSystemFont(ofSize: 12.0)
        }
        
        setFacebookLoginView()
        setEmailRegisterView()
        setEmailLoginView()
        setOtherPhoneView()
        
        let boolean =  defaults.bool(forKey: "isKiyakuAgree")
        
        if boolean {
            ToastView.appearance().cornerRadius = 10
            ToastView.appearance().backgroundColor = .gray
            ToastView.appearance().bottomOffsetPortrait = 100
            ToastView.appearance().font = .systemFont(ofSize: 16)
            Toast(text: "ユーザー登録が必要です。").show()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let boolean =  defaults.bool(forKey: "isKiyakuAgree")
        if !boolean {
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            let kiyakuAgreeVC = storyboard.instantiateViewController(withIdentifier: "KiyakuAgreeViewController")
            self.present(kiyakuAgreeVC, animated: true, completion: nil)
        }
    }
    
    func reproAnalyticsRegisterVC_ViewDidLoad() {
        
        // Custom event
        Repro.track("新規登録・ログイン画面", properties:nil)
    }
    
    func reproAnalyticsFacebookBtnTapped() {
        
        // Custom event
        Repro.track("Facebook登録・ログイン", properties:nil)
    }
    
    func reproAnalyticsEmailRegisterBtnTapped() {
        
        // Custom event
        Repro.track("メルアド新規登録画面へ", properties:nil)
    }
    
    func reproAnalyticsEmailLoginBtnTapped() {
        
        // Custom event
        Repro.track("メルアドログイン画面へ", properties:nil)
    }
    
    func setFacebookLoginView() {
        
        
        
        facebookIconImageView.clipsToBounds = true
        facebookIconImageView.layer.cornerRadius = 5
        facebookLoginView.clipsToBounds = true
        facebookLoginView.layer.cornerRadius = 5
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.facebookLogin_TouchUpInside))
        facebookLoginView.addGestureRecognizer(tapGesture)
        facebookLoginView.isUserInteractionEnabled = true
    }
    
    func setEmailRegisterView() {
        emailRegisterView.clipsToBounds = true
        emailRegisterView.layer.cornerRadius = 5
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.emailRegister_TouchUpInside))
        emailRegisterView.addGestureRecognizer(tapGesture)
        emailRegisterView.isUserInteractionEnabled = true
    }
    
    func setEmailLoginView() {
        emailLoginView.clipsToBounds = true
        emailLoginView.layer.cornerRadius = 5
        emailLoginView.layer.borderWidth = 1
        emailLoginView.layer.borderColor = UIColor.black.cgColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.emailLogin_TouchUpInside))
        emailLoginView.addGestureRecognizer(tapGesture)
        emailLoginView.isUserInteractionEnabled = true
    }
    
    func setOtherPhoneView() {
        otherPhoneLoginView.clipsToBounds = true
        otherPhoneLoginView.layer.cornerRadius = 5
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.emailLogin_TouchUpInside))
        otherPhoneLoginView.addGestureRecognizer(tapGesture)
        otherPhoneLoginView.isUserInteractionEnabled = true
    }
    
    @IBAction func close_TouchUpInside(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
        self.present(registerVC, animated: true, completion: nil)
    }
    
    
    
    @objc func facebookLogin_TouchUpInside() {
        print("facebookTap")
        
        AuthService.FBLogin(registerVC: self, emailSecondVC: nil) { (uid, isAlreadyRegistered) in
            self.reproAnalyticsFacebookBtnTapped()
            SVProgressHUD.dismiss()
            
            if isAlreadyRegistered == false {
                print("新規登録")
                
            } else {
                print("ロード完了")
                
            }
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
            self.present(registerVC, animated: true, completion: nil)
        }
    }
    
    
    @objc func emailRegister_TouchUpInside() {
        
        reproAnalyticsEmailRegisterBtnTapped()
        self.performSegue(withIdentifier: "goToRegister_Seg", sender: nil)
    }
    
    @objc func emailLogin_TouchUpInside() {
        reproAnalyticsEmailLoginBtnTapped()
        self.performSegue(withIdentifier: "goToLogin_Seg", sender: nil)
        
        
    }
    
}
