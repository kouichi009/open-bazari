//
//  CommentTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func goToUIAlertController(post: Post?, currentUid: String, comment: Comment?)
    func goToProfileUser(userId: String)
    func goToRegisterVC()
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    
    
    @IBOutlet weak var commentTextView: UITextView!
    
    
    var delegate: CommentTableViewCellDelegate?
    
//    var indexRow: Int?
    
    var goflg = false
    
    var post: Post?
    
    var comment: Comment? {
        didSet {
            updateView()
        }
    }
    
    var usermodel: UserModel? {
        didSet {
            setUpUserModel()
        }
    }
    
    
    func updateView() {
        
            guard let commentTex = comment?.commentText else {return}
        
            commentTextView.text = comment?.commentText
        print(commentTextView.text)
        
        if let timestamp = comment?.timestamp {
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) 秒前" : "\(diff.second!) 秒前"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) 分前" : "\(diff.minute!) 分前"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) 時間前" : "\(diff.hour!) 時間前"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) 日前" : "\(diff.day!) 日前"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) 週間前" : "\(diff.weekOfMonth!) 週間前"
            }
            
            timeLbl.text = timeText
        }
    }
    
    func setUpUserModel() {
        if let profileUrlStr = usermodel?.profileImageUrl {
            let profileUrl = URL(string: profileUrlStr)
            profileImageView.sd_setImage(with: profileUrl)
        }
        profileNameLbl.text = usermodel?.username
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        profileImageView.layer.cornerRadius = 15
        cellView.layer.cornerRadius = 20
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.profileImageView_TouchUpInside))
        profileImageView.addGestureRecognizer(tapGestureForLikeImageView)
        profileImageView.isUserInteractionEnabled = true
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        profileNameLbl.addGestureRecognizer(tapGestureForNameLabel)
        profileNameLbl.isUserInteractionEnabled = true
        
        profileNameLbl.text = ""
        commentTextView.text = ""
        timeLbl.text = ""
        
        
    }
    
    @objc func profileImageView_TouchUpInside() {
        print("model ",usermodel)
        print("id ", usermodel?.id)
        
        guard let _ = Api.User.CURRENT_USER?.uid else {
            delegate?.goToRegisterVC()
            return}
        
        if let uid = usermodel?.id {
            delegate?.goToProfileUser(userId: uid)
        }
    }
    
    @objc func nameLabel_TouchUpInside() {
        
        guard let _ = Api.User.CURRENT_USER?.uid else {
            delegate?.goToRegisterVC()
            return}
        if let uid = usermodel?.id {
            delegate?.goToProfileUser(userId: uid)
        }
    }
    
    @IBAction func more_TouchUpInside(_ sender: Any) {
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {
            delegate?.goToRegisterVC()
            return}
        
        self.delegate?.goToUIAlertController(post: post, currentUid: currentUid, comment: comment)
//        // create menu controller
//        let menu = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
//
//
//
//        // DELET ACTION
//        let delete = UIAlertAction(title: "削除する", style: .default) { (UIAlertAction) -> Void in
//
//            self.deleteComment()
//        }
//
//
//        // COMPLAIN ACTION
//        let complain = UIAlertAction(title: "通報する", style: .default) { (UIAlertAction) -> Void in
//
//        }
//
//        // CANCEL ACTION
//        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
//
//        // if post belongs to user, he can delete post, else he can't
//
//
//        if post?.uid == currentUid {
//            if comment?.uid == currentUid {
//                menu.addAction(delete)
//                menu.addAction(cancel)
//            } else {
//                menu.addAction(delete)
//                menu.addAction(complain)
//                menu.addAction(cancel)
//            }
//        } else {
//            if comment?.uid == currentUid {
//                menu.addAction(delete)
//                menu.addAction(cancel)
//            } else {
//                menu.addAction(complain)
//                menu.addAction(cancel)
//            }
//        }
//
        
    }
    
   
}
