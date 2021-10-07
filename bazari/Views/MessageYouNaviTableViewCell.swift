//
//  MessageYouNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/26.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class MessageYouNaviTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var uiView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
