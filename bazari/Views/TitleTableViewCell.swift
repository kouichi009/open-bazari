//
//  TitleTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
protocol TitleTableViewCellDelegate {
    func goToRegisterUserVC()
    func goToCommentVC()
}

class TitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountBtn: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentCountBtn: UIButton!
    
    var delegate: TitleTableViewCellDelegate?
    var isBlocked: Bool?
    
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let commentCount = post?.commentCount {
            if commentCount == 0 {
                commentCountBtn.setTitle("", for: UIControlState.normal)
            } else {
                commentCountBtn.setTitle("\(commentCount)", for: UIControlState.normal)
            }
        }
        
        titleLbl.text = (post?.title)!
        
        self.updateLike(post: self.post!)
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        likeCountBtn.setTitle("", for: UIControlState.normal)
        commentCountBtn.setTitle("", for: UIControlState.normal)
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func like_TouchUpInside(_ sender: Any) {
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {
            delegate?.goToRegisterUserVC()
            return}
        
        guard let isBlocked = isBlocked else {return}
        if isBlocked {
            ProgressHUD.showError("ブロックされています。")
            return;
        } else {
            
            Api.Post.incrementLikes(post: post!, onSuccess: { (post) in
                self.updateLike(post: post)
                self.post?.likes = post.likes
                self.post?.likeCount = post.likeCount
                
                if post.uid != Api.User.CURRENT_USER?.uid {
                    let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                    
                    if post.isLiked == true {
                        
                        Api.Notification.observeExistNotification(uid: post.uid!, postId: post.id!, type: "like", currentUid: currentUid) { (notificationId) in
                            
                            if notificationId == nil {
                                
                                //いいね、購入時の良い評価、売却時の良い評価どれか一つでもつけてくれたら、次アプリを起動した時に、
                                //アプリのレビューに誘導するためのUserDefaults。
                                let userDefaults = UserDefaults.standard
                                let evaCount: Int = userDefaults.integer(forKey: Config.count_forEvaluateApp) + 1
                                userDefaults.set(evaCount, forKey: Config.count_forEvaluateApp)
                                
                                let newNotificationReference = Api.Notification.REF_NOTIFICATION
                                let newAutoKey = newNotificationReference.childByAutoId().key
                                newNotificationReference.child(newAutoKey!).setValue(["checked": false, "from": Api.User.CURRENT_USER!.uid, "objectId": post.id!, "type": "like", "timestamp": timestamp, "to": post.uid!, "segmentType": Config.you])
                                let newMyNotificationReference = Api.Notification.REF_MYNOTIFICATION.child(post.uid!)
                                newMyNotificationReference.child(newAutoKey!).setValue(["timestamp": timestamp])
                                Api.Notification.REF_EXIST_NOTIFICATION.child(post.uid!).child(currentUid).child(post.id!).child("like").setValue([newAutoKey!: true])
                                
                                
                                if let postUid = post.uid {
                                    Api.User.observeUser(withId: postUid, completion: { (usermodel) in
                                        if let fcmToken = usermodel?.fcmToken {
                                            self.sendPushNotification(token: fcmToken)
                                        }
                                    })
                                }
                            }
                        }
                        
                    }
                }
            }) { (errorMessage) in
                print(errorMessage)
            }
        }
    }
    
    func sendPushNotification(token: String) {
        
        let indexNum = Config.pushNotiTitleCount
        
        guard let post = post else {return}
        var titleStr: String = post.title!
        
        if titleStr.count > indexNum {
            titleStr = String(titleStr.prefix(indexNum))
            titleStr = titleStr+"..."
        }
        let message = "「\(titleStr)」にいいねがつきました。"
        
        Api.Notification.sendNotification(token: token, message: message) { (success, error) in
            if success == true {
                print("Notification sent!")
            } else {
                print("Notification sent error!")
            }
        }
    }
    
    func updateLike(post: Post) {
        
        print("post.likes ", post.likes)
        print("post.isLiked ", post.isLiked)
        var imageName = String()
        
        if post.isLiked == nil {
            imageName = "heart"
        } else {
            imageName = post.likes == nil || !post.isLiked! ? "heart" : "heart_selected"
        }
        print("imageName ", imageName)
        
        likeButton.setImage(UIImage(named: imageName), for: UIControlState.normal)
        
        guard let count = post.likeCount else {
            return
        }
        if count != 0 {
            likeCountBtn.setTitle("\(count)", for: UIControlState.normal)
        } else {
            likeCountBtn.setTitle("", for: UIControlState.normal)
        }
        
    }
    
    
    
    
    @IBAction func comment_TouchUpInside(_ sender: Any) {
        
        if let _ = Api.User.CURRENT_USER?.uid {
            guard let isBlocked = isBlocked else {return}
            if isBlocked {
                ProgressHUD.showError("ブロックされています。")
                return;
            } else {
                delegate?.goToCommentVC()
            }
        } else {
            delegate?.goToRegisterUserVC()
        }
    }
    
    
}
