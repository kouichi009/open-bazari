//
//  ValueNumTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/15.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ValueNumTableViewCell: UITableViewCell {
    
    @IBOutlet weak var valueImageView: UIImageView!
    
    @IBOutlet weak var valueLbl: UILabel!
    
    @IBOutlet weak var valueCountLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
