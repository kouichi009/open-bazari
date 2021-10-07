//
//  TitleInputTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol TitleInputTableViewCellDelegate {
    func changeTitle(text: String)
}

class TitleInputTableViewCell: UITableViewCell {
    @IBOutlet weak var titleTextField: UITextField!
    
    var delegate: TitleInputTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }

    @objc func textFieldDidChange() {
        
        if titleTextField.text == "" || titleTextField.text == nil {
            delegate?.changeTitle(text: "")
        } else {
            delegate?.changeTitle(text: titleTextField.text!)
        }
        
    }

}
