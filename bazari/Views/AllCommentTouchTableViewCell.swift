//
//  AllCommentTouchTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class AllCommentTouchTableViewCell: UITableViewCell {
    
    var delegate: TitleTableViewCellDelegate?
    var isBlocked: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func comment_TouchUpInside(_ sender: Any) {
        
        if let _ = Api.User.CURRENT_USER?.uid {
            guard let isBlocked = isBlocked else {return}
            
            if isBlocked {
                ProgressHUD.showError("ブロックされています。")
            } else {
                delegate?.goToCommentVC()
            }
        } else {
            delegate?.goToRegisterUserVC()
        }
    }
}
