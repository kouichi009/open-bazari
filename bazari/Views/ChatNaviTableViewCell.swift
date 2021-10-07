//
//  ChatNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ChatNaviTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var cellView: UIView!
    
    var currentUid = String()
    
    var chat: Chat? {
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
        
        
        if let messageText = chat?.messageText {
            messageTextView.text = messageText
        }
        if let dateText = chat?.date {
            dateLbl.text = dateText
        }
    }
    
    func setUpUserModel() {
        if let profileImageUrlSt = usermodel?.profileImageUrl {
            let profileImageUrl = URL(string: profileImageUrlSt)
            profileImageView.sd_setImage(with: profileImageUrl)
        }
        usernameLbl.text = (usermodel?.username)!
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateLbl.text = ""
        usernameLbl.text = ""
        messageTextView.text = ""
        
        if Config.isUnderIphoneSE {
            dateLbl.font = UIFont.systemFont(ofSize: 12)
            usernameLbl.font = UIFont.systemFont(ofSize: 12)
            messageTextView.font = UIFont.systemFont(ofSize: 12)
        }
        
        cellView.clipsToBounds = true
        cellView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
