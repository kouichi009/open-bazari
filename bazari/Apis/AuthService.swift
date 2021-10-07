//
//  AuthService.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit
import SVProgressHUD

class AuthService {
    
    static func phoneAuthLogin(phoneTex: String, completed:  @escaping () -> Void ) {
        ProgressHUD.show("コードをSMSで送信")
        print(phoneTex)
        Auth.auth().languageCode = "ja"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneTex, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                print(error?.localizedDescription)
                ProgressHUD.showError("有効な電話番号を入力してください")
            } else {
                //     Auth.auth().languageCode = "ja"
                
                print("verificationID \(verificationID)")
                ProgressHUD.showSuccess("送信されました")
                let defaults = UserDefaults.standard
                defaults.set(verificationID, forKey: "authVID")
                completed()
            }
        }
    }
    
    static func FBLogin(registerVC: RegisterViewController?, emailSecondVC: EmailSecondTableViewController?, onSuccess: @escaping (String, Bool) -> Void) {
        
        if let registerVC = registerVC {
            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: registerVC) { (result, error) in
                
                
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
                self.isRegisteredFB(onSuccess: onSuccess)
            }
        }
        
        if let emailSecondVC = emailSecondVC {
            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: emailSecondVC) { (result, error) in
                
                
                if (error != nil){
                    
                    print("FB Login failed: ", error)
                    ProgressHUD.showError("ログイン失敗")
                    return
                }
                
                if let result = result {
                    
                    if result.isCancelled == true {
                        ProgressHUD.showError("ログインに失敗しました")
                        return;
                    }
                }
                self.isRegisteredFB(onSuccess: onSuccess)
            }
        }
    }
    
    
    static func isRegisteredFB(onSuccess: @escaping (String, Bool) -> Void) {
        
        SVProgressHUD.show()
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print("Something went wrong with out FB user: ", error)
                SVProgressHUD.dismiss()
                return
            }
            print("Successfully logged in with out user: ", user?.uid)
            var keyCheck = false
            Api.User.REF_USERS.observeSingleEvent(of: .value, with: {
                snapshot in
                
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    if child.key == user?.uid {
                        print("child.key", child.key)
                        keyCheck = true
                    }
                })
                
                if keyCheck == false {
                    print("新規登録")
                    
                    self.newRegisterFBDatabase(uid: (user?.uid)!, onSuccess: onSuccess)
                    
                } else {
                    print("ロード完了")
                    onSuccess((user?.uid)!, true)
                }
            })
        }
    }
    
    static func newRegisterFBDatabase(uid: String, onSuccess: @escaping (String, Bool) -> Void) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        let timestamp = Int(Date().timeIntervalSince1970)
        
        //   FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "email, name, id, gender"])
        //       .start(completionHandler:  { (connection, result, error) in
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, id, last_name, first_name, picture.type(large)"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request: ", err)
                SVProgressHUD.dismiss()
                return
            }
            
            guard let userInfo = result as? [String: Any] else { return } //handle the error
            
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                let email = userInfo["email"] as? String
                var profileImageStr = imageURL
                //プロフィール画像の設定.storageのtestノードの中
                if profileImageStr == nil {
                    profileImageStr = Config.AnonymousImageURL
                }
                
                var username = userInfo["first_name"] as? String
                if username == nil || username == "" {
                    username = "ななし"
                }
                
                let newImageUrl = URL(string: profileImageStr)!
                let imageData = try! Data(contentsOf: newImageUrl)
                let image = UIImage(data: imageData)
                let imageName = NSUUID().uuidString // Unique string to reference image
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("posts").child(imageName)
                guard let data = UIImageJPEGRepresentation(image!, 0.1) else {return}
                storageRef.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let photoUrl = url?.absoluteString {
                            AuthService.setUserInfomation(isEmailAuth: nil, profileImageUrl: photoUrl, username: username!, email: email, uid: uid, loginType: Config.LoginTypeFacebook, onSuccess: {
                                onSuccess(uid, false)
                            })
                        }
                    })
                }
            }
        }
    }
    
    static func linkEmailAuth(email: String, password: String, onSuccess: @escaping () -> Void) {
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (result, error) in
            if error != nil {
                
                SVProgressHUD.dismiss()
                
                if ((error?.localizedDescription)?.contains("password must be 6 characters"))! {
                    ProgressHUD.showError("パスワードは6文字以上にしてください。")
                    
                } else if ((error?.localizedDescription)?.contains("email address is already in use"))! {
                    ProgressHUD.showError("他のアカウントで既に登録済みのメールアドレスです。")
                    
                } else {
                    ProgressHUD.showError("登録できません。入力に不備があるようです。")
                }
                
            } else {
                Api.User.REF_USERS.child((Api.User.CURRENT_USER?.uid)!).updateChildValues(["email": email, "isEmailAuth": true], withCompletionBlock: { (error, ref) in
                    
                    SVProgressHUD.dismiss()
                    onSuccess()
                    
                    if error != nil {
                        print(error)
                    }
                })
            }
        })
    }
    
    static func signUp(profileImageUrl: String, username: String, email: String, password: String, loginType: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                
                if let uid = user?.user.uid {
                    self.setUserInfomation(isEmailAuth: true, profileImageUrl: profileImageUrl, username: username, email: email, uid: uid, loginType: loginType, onSuccess: onSuccess)
                }
                
            } else {
                //   ProgressHUD.showError("ロードに失敗しました。")
                
                print(error!.localizedDescription)
                onError(error!.localizedDescription)
                return
            }
        }
    }
    
    static func setUserInfomation(isEmailAuth: Bool?, profileImageUrl: String, username: String, email: String?, uid: String, loginType: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        let timestamp = Int(Date().timeIntervalSince1970)
        let fcmToken = UserDefaults.standard.string(forKey: "FCMToken")
        print("fcmToken: ", fcmToken)
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased(), "profileImageUrl": profileImageUrl, "loginType": loginType, "timestamp": timestamp, "email": email, "value": ["sun": 0, "cloud": 0, "rain": 0], "fcmToken": fcmToken, "isEmailAuth": isEmailAuth])
        
        let autoKey = Api.Notification.REF_MYNOTIFICATION.child(uid).childByAutoId().key
        Api.Notification.REF_MYNOTIFICATION.child(uid).child(autoKey!).setValue(["timestamp": timestamp])
        Api.Notification.REF_NOTIFICATION.child(autoKey!).setValue(["checked": false, "from": "admin", "objectId": "バザリへのご登録ありがとうございます。", "segmentType": "you", "timestamp": timestamp, "to": uid, "type": "admin"])
        
        onSuccess()
    }
    
    static func signIn(email: String, password: String, onSuccess: @escaping (String) -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess((user?.user.uid)!)
        })
    }
    
    static func updateUserInfor(username: String, imageData: Data, selfIntroText: String?, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        SVProgressHUD.show()
        let uid = Api.User.CURRENT_USER?.uid
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid!)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if let photoUrl = url?.absoluteString {
                    self.updateDatabase(profileImageUrl: photoUrl, username: username, selfIntroText: selfIntroText, onSuccess: onSuccess, onError: onError)
                }
            })
        }
    }
    
    static func updateDatabase(profileImageUrl: String, username: String, selfIntroText: String?, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "username_lowercase": username.lowercased(), "profileImageUrl": profileImageUrl, Config.selfIntroStr: selfIntroText]
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                SVProgressHUD.dismiss()
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
            
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        
        //        let store = TWTRTwitter.sharedInstance().sessionStore
        //        if let userID = store.session()?.userID {
        //            store.logOutUserID(userID)
        //        }
        //
        //        let loginManager = FBSDKLoginManager()
        //        loginManager.logOut()
        
        do {
            try Auth.auth().signOut()
            //       GIDSignIn.sharedInstance().signOut()
            onSuccess()
            
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
    }
}
