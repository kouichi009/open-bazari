//
//  BankRegisterButtonTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol BankRegisterButtonTableViewCellDelegate {
    func registerBankInfo()
}
class BankRegisterButtonTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bankRegisterButton: UIButton!
    var delegate: BankRegisterButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bankRegisterButton.layer.cornerRadius = 5
    }

    @IBAction func bankRegister_TouchUpInside(_ sender: Any) {
        bankRegisterButton.isEnabled = false
        delegate?.registerBankInfo()
    }
    

}
