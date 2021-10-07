//
//  PurchaseEvaluatePeopleTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import DLRadioButton
import UICheckbox_Swift
import KMPlaceholderTextView

protocol PurchaseEvaluatePeopleTableViewCellDelegate {
    func back2(valueStatus: String, valueComment: String)
}

class PurchaseEvaluatePeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var goodRadioButton: DLRadioButton!
    @IBOutlet weak var goodUIView: UIView!
    @IBOutlet weak var goodLbl1: UILabel!
    @IBOutlet weak var goodLbl2: UILabel!
    @IBOutlet weak var normalUIView: UIView!
    @IBOutlet weak var normalLbl1: UILabel!
    @IBOutlet weak var normalLbl2: UILabel!
    @IBOutlet weak var badUIView: UIView!
    @IBOutlet weak var badLbl1: UILabel!
    @IBOutlet weak var checkBox: UICheckbox!
    
    @IBOutlet weak var sendValueButton: UIButton!
    
    @IBOutlet weak var valueInputTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var checkLbl: UILabel!
    
    
    var delegate: PurchaseEvaluatePeopleTableViewCellDelegate?
    
    var pinkColor = UIColor()
    var labelUnSelectColor = UIColor()
    var uiViewUnSelectColor = UIColor()
    var uiViewUnSelectBorderColor = UIColor()
    
    var valueStatus = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        valueInputTextView.layer.borderWidth = 0.5
        valueInputTextView.layer.borderColor = UIColor.lightGray.cgColor
        valueInputTextView.placeholder = "商品の感想や、お礼のメッセージなどを書くと喜ばれます"
        
        pinkColor = UIColor(red: 255/255, green: 110/255, blue: 110/255, alpha: 1)
        
        labelUnSelectColor =  UIColor(red: 170/255, green: 173/255, blue: 187/255, alpha: 1)
        
        uiViewUnSelectColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        
        uiViewUnSelectBorderColor = .lightGray
        
        goodRadioButton.isSelected = true
        pressGoodRadioButton()
        
        nonAvailableButton()
        
        checkBox.layer.borderColor = UIColor.darkGray.cgColor
        checkBox.layer.borderWidth = 4
        checkBox.backgroundColor = UIColor.white
        checkBox.clipsToBounds = true
        checkBox.layer.cornerRadius = 5
        
        if Config.isUnderIphoneSE {
            checkLbl.font = UIFont.systemFont(ofSize: 12)
        }
        
        checkBox.onSelectStateChanged = { (checkBoxRef, selected) in
            
            
            if selected {
                self.availableButton()
                
            } else {
                self.nonAvailableButton()
            }
        }
    }
    
    @IBAction func sendValue_TouchUpInside(_ sender: Any) {
            sendValueButton.isEnabled = false
            
            
            delegate?.back2(valueStatus: valueStatus, valueComment: valueInputTextView.text!)
        
    }
    
    
    
    func nonAvailableButton() {
        sendValueButton.backgroundColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1)
        
        sendValueButton.setTitleColor(UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1), for: UIControlState.normal)
        
        sendValueButton.isEnabled = false
        
    }
    
    func availableButton() {
        sendValueButton.backgroundColor = pinkColor
        
        sendValueButton.setTitleColor(.white, for: UIControlState.normal)
        
        sendValueButton.isEnabled = true
        
    }
    
    
    @IBAction func radioButton_TouchUpInside(_ sender: DLRadioButton) {
        // good
        if sender.tag == 0 {
            pressGoodRadioButton()
            
        } // normal
        else if sender.tag == 1 {
            pressNormalRadioButton()
        } // bad
        else if sender.tag == 2 {
            pressBadRadioButton()
        }
    }
    
    func pressGoodRadioButton() {
        
        valueStatus = Config.sun
        
        goodUIView.layer.cornerRadius = 5
        goodUIView.clipsToBounds = true
        goodUIView.backgroundColor = UIColor.white
        goodUIView.layer.borderWidth = 0.5
        goodUIView.layer.borderColor = pinkColor.cgColor
        goodLbl1.textColor = pinkColor
        goodLbl2.textColor = pinkColor
        
        normalUIView.layer.cornerRadius = 5
        normalUIView.clipsToBounds = true
        normalUIView.backgroundColor = uiViewUnSelectColor
        normalUIView.layer.borderWidth = 0.5
        normalUIView.layer.borderColor = uiViewUnSelectBorderColor.cgColor
        normalLbl1.textColor = labelUnSelectColor
        normalLbl2.textColor = labelUnSelectColor
        
        badUIView.layer.cornerRadius = 5
        badUIView.clipsToBounds = true
        badUIView.backgroundColor = uiViewUnSelectColor
        badUIView.layer.borderWidth = 0.5
        badUIView.layer.borderColor = uiViewUnSelectBorderColor.cgColor
        badLbl1.textColor = labelUnSelectColor
    }
    
    func pressNormalRadioButton() {
        
        valueStatus = Config.cloud
        
        normalUIView.layer.cornerRadius = 5
        normalUIView.clipsToBounds = true
        normalUIView.backgroundColor = UIColor.white
        normalUIView.layer.borderWidth = 0.5
        normalUIView.layer.borderColor = pinkColor.cgColor
        normalLbl1.textColor = pinkColor
        normalLbl2.textColor = pinkColor
        
        goodUIView.layer.cornerRadius = 5
        goodUIView.clipsToBounds = true
        goodUIView.backgroundColor = uiViewUnSelectColor
        goodUIView.layer.borderWidth = 0.5
        goodUIView.layer.borderColor = uiViewUnSelectBorderColor.cgColor
        goodLbl1.textColor = labelUnSelectColor
        goodLbl2.textColor = labelUnSelectColor
        
        badUIView.layer.cornerRadius = 5
        badUIView.clipsToBounds = true
        badUIView.backgroundColor = uiViewUnSelectColor
        badUIView.layer.borderWidth = 0.5
        badUIView.layer.borderColor = uiViewUnSelectBorderColor.cgColor
        badLbl1.textColor = labelUnSelectColor
    }
    
    func pressBadRadioButton() {
        
        valueStatus = Config.rain
        
        badUIView.layer.cornerRadius = 5
        badUIView.clipsToBounds = true
        badUIView.backgroundColor = UIColor.white
        badUIView.layer.borderWidth = 0.5
        badUIView.layer.borderColor = pinkColor.cgColor
        badLbl1.textColor = pinkColor
        
        goodUIView.layer.cornerRadius = 5
        goodUIView.clipsToBounds = true
        goodUIView.backgroundColor = uiViewUnSelectColor
        goodUIView.layer.borderWidth = 0.5
        goodUIView.layer.borderColor = uiViewUnSelectBorderColor.cgColor
        goodLbl1.textColor = labelUnSelectColor
        goodLbl2.textColor = labelUnSelectColor
        
        normalUIView.layer.cornerRadius = 5
        normalUIView.clipsToBounds = true
        normalUIView.backgroundColor = uiViewUnSelectColor
        normalUIView.layer.borderWidth = 0.5
        normalUIView.layer.borderColor = uiViewUnSelectBorderColor.cgColor
        normalLbl1.textColor = labelUnSelectColor
        normalLbl2.textColor = labelUnSelectColor
    }
    
    
}


