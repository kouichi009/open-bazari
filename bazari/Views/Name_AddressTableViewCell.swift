//
//  Name_AddressTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol Name_AddressTableViewCellDelegate {
    func inputText(text: String?, type: String)
}

class Name_AddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var textField1: UITextField!
    var section: Int?
    var row: Int?
    
    var delegate: Name_AddressTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField1.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    
    @objc func textFieldDidChange() {
        
        var type = String()
        
        if section == 0 {
            switch row {
            case 0:
                type = "00"

            case 1:
                type = "01"

            case 2:
                type = "02"
            case 3:
                type = "03"
            case 4:
                type = "04"
                
            default:
                print("t")
            }
            
        } else {
            
            switch row {
            case 0:
                type = "10"
            case 1:
                return;
            case 2:
                type = "12"
            case 3:
                type = "13"
            case 4:
                type = "14"
                
            default:
                print("t")
            }
        }
        
        var tex = textField1.text
        if tex == "" {
            tex = nil
        }
        
        delegate?.inputText(text: tex, type: type)
        
    }
    
}
