//
//  SelfIntroTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class SelfIntroTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selfIntroTextView: UITextView!
    
    var usermodel: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let selfIntro = usermodel?.selfIntro {
            selfIntroTextView.text = selfIntro
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
