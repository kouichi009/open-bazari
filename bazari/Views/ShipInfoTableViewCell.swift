//
//  ShipInfoTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/11.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ShipInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var shipInfoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
