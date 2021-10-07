//
//  ProductInfoNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/26.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ProductInfoNaviTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var shipPaymentLbl: UILabel!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let postImageUrlStr = post?.imageUrls[0] {
            let photoUrl = URL(string: postImageUrlStr)
            postImageView.sd_setImage(with: photoUrl)
        }

        
        titleLbl.text = (post?.title)!
        priceLbl.text = "\(Functions.formatPrice(price: (post?.price)!))円"
        shipPaymentLbl.text = (post?.shipPayer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLbl.text = ""
        priceLbl.text = ""
        shipPaymentLbl.text = ""

        if Config.isUnderIphoneSE {
            titleLbl.font = UIFont.systemFont(ofSize: 12)
            priceLbl.font = UIFont.systemFont(ofSize: 12)
            shipPaymentLbl.font = UIFont.systemFont(ofSize: 12)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
