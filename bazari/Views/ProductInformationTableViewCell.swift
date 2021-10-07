//
//  ProductInformationTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ProductInformationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
