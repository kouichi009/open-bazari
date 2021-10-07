//
//  ProductExplainInputTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class ProductExplainInputTableViewCell: UITableViewCell {
    
    @IBOutlet weak var explainTextView: KMPlaceholderTextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        explainTextView.isUserInteractionEnabled = false
        explainTextView.placeholder = "商品の状態などを記載してください。\n 例）3年前ぐらいに5万円で購入した一眼レフレンズです。傷が多々あります。動作に関しては問題ありません。"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
