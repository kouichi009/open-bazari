//
//  HeaderProfileCollectionReusableView.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/18.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import ReadMoreTextView
import KMPlaceholderTextView

protocol HeaderProfileCollectionReusableViewDelegate {
    func changeTextViewHeight(height: CGFloat?)
    func unBlockAlert(title: String, message: String, blockFlg: Bool)
    func goToValueVC(userId: String)

}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var postCountBtn: UIButton!
    @IBOutlet weak var followCountBtn: UIButton!
    @IBOutlet weak var followerCountBtn: UIButton!
    @IBOutlet weak var followLbl: UILabel!
    @IBOutlet weak var followerLbl: UILabel!
    
    
    @IBOutlet weak var userNameLbl: UILabel!
    
    
    @IBOutlet weak var selfIntroTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var selfIntroHeightConstraint: NSLayoutConstraint!
    
    var defaultHeight: CGFloat?
    var readMoreFlg = false

    
    @IBOutlet weak var readmoreBtn: UIButton!
    @IBOutlet weak var followActionBtn: UIButton!
    
    var buttonTitles = ["フォローする","フォロー中","ブロック中"]
    

    var isBlocked = false
    
    @IBOutlet weak var uiViewTransaction: UIView!
    @IBOutlet weak var sunCountLbl: UILabel!
    @IBOutlet weak var cloudCountLbl: UILabel!
    @IBOutlet weak var rainCountLbl: UILabel!
    
    
    var myPostCount = 0
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    
    var usermodel: UserModel? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sunCountLbl.text = ""
        cloudCountLbl.text = ""
        rainCountLbl.text = ""
        postCountBtn.setTitle("", for: UIControlState.normal)
        followCountBtn.setTitle("", for: UIControlState.normal)
        followerCountBtn.setTitle("", for: UIControlState.normal)
        userNameLbl.text = ""
        selfIntroTextView.text = ""
        
        
        if Config.isUnderIphoneSE {
            profileImageView.layer.cornerRadius = 25
        } else {
            profileImageView.layer.cornerRadius = 35
        }
        profileImageView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToValueVC))
        uiViewTransaction.addGestureRecognizer(tapGesture)
        uiViewTransaction.isUserInteractionEnabled = true
        
        if let followBtn = self.followActionBtn {
            followBtn.isEnabled = false
        }
        
        clear()
    }
    
    @objc func goToValueVC() {
        print("goToValueVC")
        if let _ = usermodel?.id {
            delegate?.goToValueVC(userId: (usermodel?.id)!)
        }
    }
    
  
    func updateView() {
        
        if let photoUrlString = usermodel!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl)
        }
        
        userNameLbl.text = usermodel?.username
        
        sunCountLbl.text = "\((usermodel?.sun)!)"
        cloudCountLbl.text = "\((usermodel?.cloud)!)"
        rainCountLbl.text = "\((usermodel?.rain)!)"
        
        
        if let selfIntro = usermodel?.selfIntro {
            selfIntroTextView.text = selfIntro
            readmoreBtn.isHidden = false
            
        } else {
            readmoreBtn.isHidden = true
            selfIntroTextView.text = ""
        }
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
        
        Api.Follow.fetchCountFollowing(userId: (self.usermodel?.id)!) { (count) in
            self.followCountBtn.setTitle("\(count)", for: UIControlState.normal)
        }
        
        Api.Follow.fetchCountFollowers(userId: (self.usermodel?.id)!) { (count) in
            self.followerCountBtn.setTitle("\(count)", for: UIControlState.normal)
        }
        
        postCountBtn.setTitle("\(myPostCount)", for: UIControlState.normal)
 
        if let followBtn = self.followActionBtn {
            if usermodel?.id == currentUid {
                followBtn.isHidden = true
            } else {
                followBtn.isEnabled = true
                
                if isBlocked {
                    updateStateToBlockButton()
                } else {
                    updateStateFollowButton()
                }
            }
        }
    }
    
    func updateStateToBlockButton() {
        followActionBtn.layer.borderWidth = 1
        followActionBtn.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followActionBtn.layer.cornerRadius = 5
        followActionBtn.clipsToBounds = true
        
        followActionBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        followActionBtn.backgroundColor = UIColor.lightGray
        followActionBtn.setTitle("ブロック中", for: UIControlState.normal)
    }
    
    func updateStateFollowButton() {
        if usermodel!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        followActionBtn.layer.borderWidth = 1
        followActionBtn.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followActionBtn.layer.cornerRadius = 5
        followActionBtn.clipsToBounds = true
        
        followActionBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        followActionBtn.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        followActionBtn.setTitle("フォローする", for: UIControlState.normal)

    }
    
    func configureUnFollowButton() {
        followActionBtn.layer.borderWidth = 1
        followActionBtn.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followActionBtn.layer.cornerRadius = 5
        followActionBtn.clipsToBounds = true
        
        followActionBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
        followActionBtn.backgroundColor = UIColor.clear
        followActionBtn.setTitle("フォロー中", for: UIControlState.normal)

    }
    
    
    @IBAction func followButton_TouchUpInside(_ sender: UIButton) {
        
        if buttonTitles[0] == sender.currentTitle {
            
            configureUnFollowButton()
            if usermodel?.isFollowing == nil {
                return;
            }
            
            if usermodel!.isFollowing! == false {
                Api.Follow.followAction(withUser: usermodel!.id!)
                configureUnFollowButton()
                usermodel!.isFollowing! = true
            }
            
        } else if buttonTitles[1] == sender.currentTitle {
            
            configureFollowButton()
            
            if usermodel?.isFollowing == nil {
                return;
            }
            
            if usermodel!.isFollowing! == true {
                Api.Follow.unFollowAction(withUser: usermodel!.id!)
                configureFollowButton()
                usermodel!.isFollowing! = false
            }
        } else {
            delegate?.unBlockAlert(title: "ブロックを解除する", message: "", blockFlg: false)
            
        }
    }
    
    
    @IBAction func readMoreOrLess_TouchUpInside(_ sender: Any) {
        if !readMoreFlg {
            readMoreFlg = true
            readmoreBtn.setTitle("閉じる", for: UIControlState.normal)
            selfIntroHeightConstraint.constant = selfIntroTextView.contentSize.height
            delegate?.changeTextViewHeight(height: self.selfIntroTextView.contentSize.height)
        } else {
            readMoreFlg = false
            readmoreBtn.setTitle("自己紹介をもっと見る", for: UIControlState.normal)
            selfIntroHeightConstraint.constant = defaultHeight!
            delegate?.changeTextViewHeight(height: nil)
        }
        
    }
    
    
    func configureReadMore() {
        readmoreBtn.setTitle("自己紹介をもっと見る", for: UIControlState.normal)
        readmoreBtn.addTarget(self, action: #selector(self.readMoreAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func readMoreAction() {
        selfIntroHeightConstraint.constant = selfIntroTextView.contentSize.height
        delegate?.changeTextViewHeight(height: self.selfIntroTextView.contentSize.height)
//        readmoreBtn.removeTarget(self, action: #selector(self.readMoreAction), for: UIControlEvents.touchUpInside)
        configureReadLess()
    }
    
    func configureReadLess() {
        readmoreBtn.setTitle("閉じる", for: UIControlState.normal)
        readmoreBtn.addTarget(self, action: #selector(self.readLessAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func readLessAction() {
        selfIntroHeightConstraint.constant = defaultHeight!
        delegate?.changeTextViewHeight(height: nil)
        configureReadMore()


    }
    
    func clear() {
        readmoreBtn.setTitle("自己紹介をもっと見る", for: UIControlState.normal)
        defaultHeight = selfIntroHeightConstraint.constant
        self.postCountBtn.setTitle("0", for: UIControlState.normal)
        self.followCountBtn.setTitle("0", for: UIControlState.normal)
        self.followerCountBtn.setTitle("0", for: UIControlState.normal)
    }
}
