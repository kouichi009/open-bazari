//
//  EmailSecondTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class EmailSecondTableViewController: UITableViewController {
    
    var isAlredyRegistered = Bool()
    var usermodel: UserModel?
    var currentUid = String()
    var isSecureText: Bool?
    var emailText: String?
    var passwordText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "メールアドレス登録"
        
        
        Api.User.observeUser(withId: currentUid) { (usermodel) in
            
            if let usermodel = usermodel {
                self.usermodel = usermodel
                
                if let _ = usermodel.isEmailAuth {
                    self.isAlredyRegistered = true
                } else {
                    self.isAlredyRegistered = false
                    
                    if let email = usermodel.email {
                        self.emailText = email
                        
                    }
                }
                
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 3 {
            return 80
        } else {
            return 44
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if isAlredyRegistered {
            return 1
        } else {
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if usermodel == nil {
            return 0
        } else {
            return 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell00", for: indexPath) as! EmailLoginTableViewCell
            cell.delegate = self
            
            if isAlredyRegistered {
                
                if let usermodel = usermodel {
                    cell.emailTextField.text = "(登録済み): "+usermodel.email!
                    cell.emailTextField.isEnabled = false
                    cell.emailTextField.isUserInteractionEnabled = false
                    cell.emailTextField.textColor = UIColor.gray
                }
            } else {
                if let emailText = emailText {
                    cell.emailTextField.text = emailText
                }
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell01", for: indexPath) as! EmailLoginTableViewCell
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell02", for: indexPath) as! EmailLoginTableViewCell
            cell.delegate = self
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell03", for: indexPath) as! EmailLoginTableViewCell
            cell.delegate = self
            return cell
            
        default:
            print("t")
        }
        
        return UITableViewCell()
    }
    
    func facebookLogin() {
        AuthService.FBLogin(registerVC: nil, emailSecondVC: self) { (uid, isAlreadyRegistered) in
                    
            AuthService.linkEmailAuth(email: self.emailText!, password: self.passwordText!, onSuccess: {
                
                _ = self.navigationController?.popViewController(animated: true)
                
            })
        }
    }
}



extension EmailSecondTableViewController: EmailLoginTableViewCellDelegate {
    
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
        
        if let usermodel = usermodel {
            if usermodel.loginType == Config.LoginTypeFacebook {
                facebookLogin()
            }
        }
        
    }
    
    func isSecureText(isSecure: Bool) {
        self.isSecureText = isSecure
        self.tableView.reloadData()
    }
}


