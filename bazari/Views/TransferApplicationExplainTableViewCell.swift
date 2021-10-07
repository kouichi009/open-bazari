//
//  TransferApplicationExplainTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/04.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import FRHyperLabel

protocol TransferApplicationExplainTableViewCellDelegate {
    func goToDetailTransfer()
}

class TransferApplicationExplainTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var applicationScheduleLbl: FRHyperLabel!
    
    var delegate: TransferApplicationExplainTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbl1.text = "・一月あたりに振込申請できる金額は\(Functions.formatPrice(price: Config.minimumTransferApplyPrice))円〜\(Functions.formatPrice(price: Config.maximumTransferApplyPrice))円です。\n・申請額が9,999円以下の場合、210円の振込手数料がかかります。"
        
        
        applicationScheduleLbl.setLinkForSubstring("こちら") { (_, _) in
            print("タップしたよ！")
            self.delegate?.goToDetailTransfer()
        }
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
