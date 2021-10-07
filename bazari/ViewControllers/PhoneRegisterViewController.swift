//
//  PhoneRegisterViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/09.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Repro.RPREventProperties

class PhoneRegisterViewController: UIViewController {

    var phoneNumberTextField: SkyFloatingLabelTextField!
    var button1: UIButton!
    var label1: UILabel!
    let maxLength = 11

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPhoneNumberTextField()
        createlabel1()
        createButton()
        handleTextField()
        reproAnalyticsPhoneRegister_ViewDidLoad()
    }
    
    func reproAnalyticsPhoneRegister_ViewDidLoad() {
        
        // Custom event
        Repro.track("携帯番号新規登録画面", properties:nil)
    }
    
    func reproAnalyticsSendSMS() {
        
        // Custom event
        Repro.track("SMS認証送信", properties:nil)
    }
    
    func reproAnalyticsSkip() {
        // Custom event
        Repro.track("SMS認証スキップ1", properties:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textFieldDidChange()
    }
    
    func createPhoneNumberTextField() {
        phoneNumberTextField = SkyFloatingLabelTextField()
        phoneNumberTextField.font = UIFont.boldSystemFont(ofSize: 26)
        phoneNumberTextField.keyboardType = UIKeyboardType.phonePad
        phoneNumberTextField.placeholder = "携帯番号 (11ケタ)"
        phoneNumberTextField.title = "携帯番号 (11ケタ)"
        self.view.addSubview(phoneNumberTextField)
        phoneNumberTextFieldLayout()
    }
    
    func phoneNumberTextFieldLayout() {
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        phoneNumberTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        phoneNumberTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        phoneNumberTextField.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
    }
    
    func createlabel1() {
        label1 = UILabel()
        label1.tintColor = UIColor.gray
        label1.text = "[次へ]をタップすると、このアプリから認証SMSが送信されます。"
        label1.textColor = UIColor.gray
        label1.numberOfLines = 2
        self.view.addSubview(label1)
        label1Layout()
    }
    
    func label1Layout() {
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 50).isActive = true
        label1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        label1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        label1.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    func createButton() {
        button1 = UIButton(type: .system)
        
        button1.backgroundColor = UIColor.darkGray
        //        button1.titleLabel?.textColor = UIColor.white
        button1.tintColor = UIColor.lightGray
        button1.layer.cornerRadius = 15.0
        button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button1.setTitle("次へ", for: UIControlState.normal)
        button1.isEnabled = false
        button1.addTarget(self, action: #selector(self.goToVerifyVC), for: UIControlEvents.touchUpInside)
        view.addSubview(button1)
        
        buttonLayout()
    }
    
    func buttonLayout() {
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10).isActive = true
        button1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        button1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        button1.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    @objc func goToVerifyVC() {
        
        AuthService.phoneAuthLogin(phoneTex: "+81" + phoneNumberTextField.text!, completed: {
            
            self.reproAnalyticsSendSMS()
            self.performSegue(withIdentifier: "VerifyPhone_Seg", sender: self.phoneNumberTextField.text!)
        })
    }
    
    
    func handleTextField() {
        phoneNumberTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        
        
    }
    
    @IBAction func skip_TouchUpInside(_ sender: Any) {
        self.reproAnalyticsSkip()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
        self.present(registerVC, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange() {
        button1.isEnabled = true
        
        //////////////////////////////////////////
//        button1.isEnabled = false
//        button1.tintColor = UIColor.lightGray
//
//        let length = phoneNumberTextField.text?.characters.count
//        var tex = phoneNumberTextField.text
//
//        if (length! > maxLength) {
//            let index = tex?.index((tex?.startIndex)!, offsetBy: maxLength)
//            phoneNumberTextField.text = phoneNumberTextField.text?.substring(to: index!)
//        }
//
//        if length! >= maxLength {
//            button1.isEnabled = true
//            button1.tintColor = UIColor.white
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "VerifyPhone_Seg" {
            
            let verifyVC = segue.destination as! VerifyPhoneViewController
            let phoneNumber  = sender as! String
            verifyVC.phoneNumber = phoneNumber
        }
    }
}
