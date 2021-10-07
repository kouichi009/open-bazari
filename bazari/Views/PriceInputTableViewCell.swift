//
//  PriceInputTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol PriceInputTableViewCellDelegate {
    func changePrice(inputPrice: Int?)
}

class PriceInputTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var priceInputTextField: UITextField!
    
    @IBOutlet weak var commisionLbl: UILabel!
    @IBOutlet weak var profitLbl: UILabel!

    var delegate: PriceInputTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        commisionLbl.text = ""
        profitLbl.text = ""
        
        priceInputTextField.delegate = self

        priceInputTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        
        if priceInputTextField.text == "" || priceInputTextField.text == nil {
            commisionLbl.text = ""
            profitLbl.text = ""
            
            delegate?.changePrice(inputPrice: nil)
            return;
        }
        
        if let inputPrice = priceInputTextField.text {
            let inputPriceInteger = Int(inputPrice)
            
            if inputPriceInteger! < Config.minimumPrice {
                commisionLbl.text = ""
                profitLbl.text = ""
                delegate?.changePrice(inputPrice: inputPriceInteger)
                return;
            }
            var myNumber = Double(inputPriceInteger!)
       //     var myNumber = NSNumber(value: inputPriceInteger!) as! CGFloat
            myNumber = myNumber * Config.commisionRate
            let myInt = Int(myNumber)
           commisionLbl.text = "￥\(myInt)"
            
            let profit = inputPriceInteger! - myInt
            profitLbl.text = "￥\(profit)"
            
            delegate?.changePrice(inputPrice: inputPriceInteger)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
