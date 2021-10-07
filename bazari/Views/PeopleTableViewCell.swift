//
//  PeopleTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/19.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selfIntroLbl: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var isBlockedFlg = false
    
    var usermodel: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        nameLabel.text = usermodel?.username
        if let photoUrlString = usermodel?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            print("photoUrl \(photoUrl)")
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
            
        }
        
        if let selfIntroduction = usermodel?.selfIntro {
            selfIntroLbl.text = selfIntroduction
        } else {
            selfIntroLbl.text = ""
        }
        
       
        
    }
    
    func updateStateFollowButton() {
        if usermodel!.isFollowing! {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        
        followButton.setImage(#imageLiteral(resourceName: "addPeople"), for: UIControlState.normal)
        //   followButton.setTitle("フォローする", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    
    func configureUnFollowButton() {
        
        followButton.setImage(#imageLiteral(resourceName: "addedPeople"), for: UIControlState.normal)
        //   followButton.setTitle("フォロー中", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction() {
        
        if isBlockedFlg {
            ProgressHUD.showError("ブロックされています。")
            return;
        }
        
      
        
        if usermodel?.isFollowing == nil {
            return;
        }
        
        if self.usermodel!.isFollowing! == false {
            Api.Follow.followAction(withUser: self.usermodel!.id!)
            self.configureUnFollowButton()
            self.usermodel!.isFollowing! = true
        }
        
        
    }
    
    @objc func unFollowAction() {
        
        if isBlockedFlg {
            ProgressHUD.showError("ブロックされています。")
            return;
        }
        
        
        
        if usermodel?.isFollowing == nil {
            return;
        }
        
        if usermodel!.isFollowing! == true {
            Api.Follow.unFollowAction(withUser: usermodel!.id!)
            configureFollowButton()
            usermodel!.isFollowing! = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGesture)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func nameLabel_TouchUpInside() {
        if let id = usermodel?.id {
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
