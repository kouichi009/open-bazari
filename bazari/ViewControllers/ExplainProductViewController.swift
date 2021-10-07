//
//  ExplainProductViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/13.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol ExplainProductViewControllerDelegate {
    func explainProduct(explainText: String)
}

class ExplainProductViewController: UIViewController {

    var tex: String?
    
    var textView: UITextView = {
        let text = UITextView()
        return text
    }()
    
    var width = CGFloat()
    var height = CGFloat()
    
    var delegate: ExplainProductViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        
        let screenSize = UIScreen.main.bounds
        width = screenSize.size.width
        height = screenSize.size.height
        textView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        if tex == nil {
            textView.text = ""
        } else {
            textView.text = tex!
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        print(notification)
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            
            self.textView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height - keyboardFrame!.height)
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.textView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var backStr = textView.text
        backStr = backStr?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        delegate?.explainProduct(explainText: backStr!)
    }
    

}
