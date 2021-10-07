//
//  KiyakuAgreeViewController.swift
//  bazaar
//
//  Created by koichi nakanishi on H30/10/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import FRHyperLabel

class KiyakuAgreeViewController: UIViewController {
    
    @IBOutlet weak var kiyakuLbl: FRHyperLabel!
    let linkText1 = "利用規約"

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToKiyakuText))
        kiyakuLbl.addGestureRecognizer(tapGesture)
        kiyakuLbl.isUserInteractionEnabled = true
        
        kiyakuLbl.setLinkForSubstring(linkText1) { (_, _) in
           
            self.goToKiyakuText()
        }
        
        
    }
    
    @objc func goToKiyakuText() {
        
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let kiyakuTextVC = storyboard.instantiateViewController(withIdentifier: "KiyakuTextViewController")
        self.present(kiyakuTextVC, animated: true, completion: nil)
    }
    
    @IBAction func agree_TouchUpInside(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isKiyakuAgree")
        ProgressHUD.showSuccess("規約に同意しました。")
        self.performSegue(withIdentifier: "goToRegisterVC_Seg", sender: nil)
    }
    

}
