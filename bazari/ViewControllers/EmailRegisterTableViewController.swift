//
//  EmailRegisterTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/06.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import Repro.RPREventProperties


class EmailRegisterTableViewController: UITableViewController {
    
    var isSecureText: Bool?
    var emailText: String?
    var passwordText: String?
    var usernameText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "新規登録"
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 4 {
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
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath) as! EmailRegisterTableViewCell
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! EmailRegisterTableViewCell
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! EmailRegisterTableViewCell
            
            cell.delegate = self

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! EmailRegisterTableViewCell
            cell.delegate = self
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4", for: indexPath) as! EmailRegisterTableViewCell
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension EmailRegisterTableViewController: EmailRegisterTableViewCellDelegate {
    
    func tapRegister() {
        
        if emailText == "" || emailText == nil {
            ProgressHUD.showError("メールアドレスを入力してください。")
            return;
        } else if passwordText == "" || passwordText == nil {
            ProgressHUD.showError("パスワードを入力してください。")
            return;
        } else if usernameText == "" || usernameText == nil {
            ProgressHUD.showError("ニックネームを入力してください。")
            return;
        }
        
        SVProgressHUD.show()
        
        AuthService.signUp(profileImageUrl: Config.AnonymousImageURL, username: usernameText!, email: emailText!, password: passwordText!, loginType: Config.LoginTypeEmail, onSuccess: {
            print("SignUpSuccess")
            SVProgressHUD.dismiss()
            ProgressHUD.showSuccess("新規登録完了")
            self.reproAnalyticsEmailRegister()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registerVC = storyboard.instantiateViewController(withIdentifier: "TabBarId")
            self.present(registerVC, animated: true, completion: nil)

        }) { (error) in
            SVProgressHUD.dismiss()
            print((error?.localizedLowercase)!)
            
            if ((error?.localizedLowercase)?.contains("password must be 6 characters"))! {
                ProgressHUD.showError("パスワードは6文字以上にしてください。")
            
            } else if ((error?.localizedLowercase)?.contains("email address is already in use"))! {
                ProgressHUD.showError("他のアカウントで既に登録済みのメールアドレスです。")
                
            } else {
                ProgressHUD.showError("登録できません。入力に不備があるようです。")
            }
        }
    }
    
    func reproAnalyticsEmailRegister() {
        
        // Custom event
        Repro.track("メルアド新規登録", properties:nil)
    }
    
    func inputText(text: String, type: String) {
        
        if type == "email" {
            self.emailText = text
        } else if type == "password" {
            self.passwordText = text
        } else if type == "username" {
            self.usernameText = text
        }
    }
    
    func isSecureText(isSecure: Bool) {
        self.isSecureText = isSecure
        self.tableView.reloadData()
    }
}
