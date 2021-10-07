//
//  ProfileEditTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/07.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import SVProgressHUD

protocol ProfileEditTableViewControllerDelegate {
    func updateProfile()
}

class ProfileEditTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var selfIntroTextView: KMPlaceholderTextView!
    @IBOutlet weak var chageProfileBtn: UIButton!
    
    var selectedImage: UIImage?
    
    var currentUid = String()
    
    var delegate: ProfileEditTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        selfIntroTextView.placeholder = "ここに自己紹介文を記入してください。"
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImageView))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tapGesture1)
        profileImageView.isUserInteractionEnabled = true
        chageProfileBtn.addGestureRecognizer(tapGesture2)
        chageProfileBtn.isUserInteractionEnabled = true
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            
            SVProgressHUD.show()
            Api.User.observeUser(withId: currentUid) { (usermodel) in
                
                if let usermodel = usermodel {
                    var image = UIImage()
                    if let imageUrlStr = usermodel.profileImageUrl {
                        let url = URL(string: imageUrlStr)
                        if let data = try? Data(contentsOf: url!) {
                            image = UIImage(data: data)!
                            self.selectedImage = image
                        }
                    }
                    self.usernameTextField.text = usermodel.username
                    self.profileImageView.image = image
                    
                    if let selfIntro = usermodel.selfIntro {
                        self.selfIntroTextView.text = selfIntro
                    }
                }
                
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func save_TouchUpInside(_ sender: Any) {
        
        if usernameTextField.text == "" {
            ProgressHUD.showError("ニックネームを入力してください。")
            return;
        }
        
        var text = selfIntroTextView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if text == "" {
            text = nil
        }
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            
            AuthService.updateUserInfor(username: usernameTextField.text!, imageData: imageData, selfIntroText: text, onSuccess: {
                SVProgressHUD.dismiss()
                self.delegate?.updateProfile()
                _ = self.navigationController?.popViewController(animated: true)
                print("seikou!!")
            }, onError: { (errorMessage) in
                print("errorMessage ", errorMessage)
                SVProgressHUD.dismiss()
                
            })
        }
    }
}

extension ProfileEditTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

