//
//  EmailLoginTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/07.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import Repro.RPREventProperties


class EmailLoginTableViewController: UITableViewController {
    
    
    var isSecureText: Bool?
    var emailText: String?
    var passwordText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ログイン"
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 3 {
            return 80
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath) as! EmailLoginTableViewCell
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! EmailLoginTableViewCell
            cell.delegate = self
            if let isSecureText = self.isSecureText {
                
                if isSecureText {
                    cell.passwordTextField.isSecureTextEntry = true
                    cell.passwordTextField.keyboardType = .alphabet
                } else {
                    cell.passwordTextField.isSecureTextEntry = false
                }
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! EmailLoginTableViewCell
            
            cell.delegate = self
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! EmailLoginTableViewCell
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension EmailLoginTableViewController: EmailLoginTableViewCellDelegate {
    
    func inputText(text: String, type: String) {
        if type == "email" {
            self.emailText = text
        } else if type == "password" {
            self.passwordText = text
        }
    }
    
    func tapLogin() {
        if emailText == "" || emailText == nil {
            ProgressHUD.showError("メールアドレスを入力してください。")
            return;
        } else if passwordText == "" || passwordText == nil {
            ProgressHUD.showError("パスワードを入力してください。")
            return;
        }
        
        SVProgressHUD.show()
        
        AuthService.signIn(email: emailText!, password: passwordText!, onSuccess: { (uid) in
            print("SignInSuccess!")
            
            Api.User.observeUser(withId: uid, completion: { (usermodel) in
                
                SVProgressHUD.dismiss()
                self.reproAnalyticsEmailLogin()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
                self.present(registerVC, animated: true, completion: nil)
                
            })
            
        }) { (error) in
            SVProgressHUD.dismiss()
            print((error?.localizedLowercase)!)
            ProgressHUD.showError("メールアドレス・パスワードが一致しません。")
        }
    }
    
    func isSecureText(isSecure: Bool) {
        self.isSecureText = isSecure
        self.tableView.reloadData()
    }
    
    func reproAnalyticsEmailLogin() {
        
        // Custom event
        Repro.track("メルアドログイン", properties:nil)
    }
    
}

