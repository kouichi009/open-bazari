//
//  ValueTransactionTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ValueTransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var valueLbl: UILabel!
    
    var usermodel: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let _ = usermodel?.sun {
            valueLbl.text = "評価 : \(((usermodel?.sun)! + (usermodel?.cloud)! + (usermodel?.rain)!))"
        }
        
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        valueLbl.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
