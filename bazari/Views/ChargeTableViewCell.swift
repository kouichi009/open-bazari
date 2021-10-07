//
//  ChargeTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/05.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ChargeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLbl.text = ""
        statusLbl.text = ""
        priceLbl.text = ""
        dateLbl.text = ""
        
        statusLbl.backgroundColor = UIColor.white
        statusLbl.layer.borderWidth = 0.5
        statusLbl.layer.borderColor = UIColor.darkGray.cgColor
        statusLbl.layer.cornerRadius = 5
        statusLbl.font = UIFont.systemFont(ofSize: 13)
        statusLbl.textColor = UIColor.darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
