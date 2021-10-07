//
//  ShipInfoWithSubTitleTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/11.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ShipInfoWithSubTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
    @IBOutlet weak var recommendLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        recommendLbl.text = "売れやすい"
        
        recommendLbl.backgroundColor = UIColor.white

        recommendLbl.layer.borderWidth = 0.5
        recommendLbl.layer.borderColor = UIColor.red.cgColor
        recommendLbl.layer.cornerRadius = 5
        recommendLbl.font = UIFont.systemFont(ofSize: 13)
        recommendLbl.textColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
