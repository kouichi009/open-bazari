//
//  ProfileMenuCollectionViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/20.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ProfileMenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var stringLbl: UILabel!
    @IBOutlet weak var redDotImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        redDotImageView.isHidden = true
    }
}
