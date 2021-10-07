//
//  ValueCommentTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/15.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ValueCommentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var valueImageView: UIImageView!
    @IBOutlet weak var valueStatusLbl: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var uiView: UIView!
    
    @IBOutlet weak var uiViewHeightConstraint: NSLayoutConstraint!
    
    var value: Value? {
        didSet {
            updateView()
        }
    }
    
    var usermodel: UserModel? {
        didSet {
            setUpUser()
        }
    }
    
    func updateView() {
        
        commentTextView.text = value?.valueComment
        
        if let timestamp = value?.timestamp {
            let dateStr = dateString(timestamp: timestamp)
            dateLbl.text = dateStr

        }
        
        print(commentTextView.contentSize.height)
        
        if value?.valueStatus == "sun" {
            valueImageView.image = #imageLiteral(resourceName: "Sun")
            valueStatusLbl.text = "よい評価"
        } else if value?.valueStatus == "cloud" {
            valueImageView.image = #imageLiteral(resourceName: "Cloud")
            valueStatusLbl.text = "ふつうの評価"
            
        } else if value?.valueStatus == "rain" {
            valueImageView.image = #imageLiteral(resourceName: "Rain")
            valueStatusLbl.text = "わるい評価"
        }
    }
    
    func setUpUser() {

        usernameLbl.text = (usermodel?.username)!
        if let profileImageUrlStr = usermodel?.profileImageUrl {
            let profileImageUrl = URL(string: profileImageUrlStr)
            profileImage.sd_setImage(with: profileImageUrl)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLbl.text = ""
        commentTextView.text = ""
        profileImage.layer.cornerRadius = 15
        profileImage.clipsToBounds = true
        uiView.layer.cornerRadius = 20
        uiView.clipsToBounds = true
        
        if Config.isUnderIphoneSE {
            valueStatusLbl.font = UIFont.systemFont(ofSize: 10)
            dateLbl.font = UIFont.systemFont(ofSize: 8)
            commentTextView.font = UIFont.systemFont(ofSize: 12)
        }
    }

    func dateString(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        return dateString
        
    }


}
