//
//  ProductStatusChooseTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/11.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ProductStatusChooseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLbl: UILabel!
    
    @IBOutlet weak var subTItleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subTItleLbl.numberOfLines = 0
        subTItleLbl.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
