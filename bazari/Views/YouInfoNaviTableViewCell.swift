//
//  YouInfoNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/26.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol YouInfoNaviTableViewCellDelegate {
    func goToValueVC(userId: String)
    func goToUserVC(userId: String)
}

class YouInfoNaviTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var sunCountLbl: UILabel!
    @IBOutlet weak var cloudCountLbl: UILabel!
    @IBOutlet weak var rainCountLbl: UILabel!
    
    @IBOutlet weak var uiViewValue: UIView!
    
    var delegate: YouInfoNaviTableViewCellDelegate?
    
    var usermodel: UserModel? {
        didSet {
            setUpUserModel()
        }
    }
    
    func setUpUserModel() {
        if let profileImageUrlStr = usermodel?.profileImageUrl {
            let profileImageUrl = URL(string: profileImageUrlStr)
            profileImageView.sd_setImage(with: profileImageUrl)
        }
        
        userNameLbl.text = (usermodel?.username)!
        sunCountLbl.text = "\((usermodel?.sun)!)"
        cloudCountLbl.text = "\((usermodel?.cloud)!)"
        rainCountLbl.text = "\((usermodel?.rain)!)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        setuiViewTap()
        setUserTap()
        userNameLbl.text = ""
        sunCountLbl.text = ""
        cloudCountLbl.text = ""
        rainCountLbl.text = ""
    }
    
    func setuiViewTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToValueVC))
        uiViewValue.addGestureRecognizer(tapGesture)
        uiViewValue.isUserInteractionEnabled = true
    }
    func setUserTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToUserVC))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.goToUserVC))
        userNameLbl.addGestureRecognizer(tapGesture2)
        userNameLbl.isUserInteractionEnabled = true
    }
    
    @objc func goToValueVC() {
        delegate?.goToValueVC(userId: (usermodel?.id)!)
    }
    
    @objc func goToUserVC() {
        delegate?.goToUserVC(userId: (usermodel?.id)!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
