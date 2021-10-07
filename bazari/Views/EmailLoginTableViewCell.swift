//
//  EmailLoginTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/07.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import UICheckbox_Swift

protocol EmailLoginTableViewCellDelegate {
    func isSecureText(isSecure: Bool)
    func inputText(text: String, type: String)
    func tapLogin()
}

class EmailLoginTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkBox: UICheckbox!
    
    var delegate: EmailLoginTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let _ = emailTextField {
            emailTextField.delegate = self
            emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        }
        
        if let _ = passwordTextField {
            passwordTextField.delegate = self
            passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        }

        
        if let _ = checkBox {
            checkBox.layer.borderColor = UIColor.darkGray.cgColor
            checkBox.layer.borderWidth = 4
            checkBox.clipsToBounds = true
            checkBox.layer.cornerRadius = 5
            checkBox.onSelectStateChanged = { (checkBoxRef, selected) in
                
                if selected {
                    self.nonAvailableButton()
                    
                } else {
                    self.availableButton()
                    
                }
            }
        }
    }
    
    @objc func textFieldDidChange() {
        
        if let _ = emailTextField {
            delegate?.inputText(text: emailTextField.text!, type: "email")
        }
        
        if let _ = passwordTextField {
            delegate?.inputText(text: passwordTextField.text!, type: "password")
        }
    }
    
    func availableButton() {
        delegate?.isSecureText(isSecure: true)
    }
    
    func nonAvailableButton() {
        delegate?.isSecureText(isSecure: false)
    }
    
    @IBAction func login_TouchUpInside(_ sender: Any) {
        delegate?.tapLogin()
    }
}
