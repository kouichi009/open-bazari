//
//  PurchaseListTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class PurchaseListTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var shouldDoLbl: UILabel!
    
    
    @IBOutlet weak var priceLbl: UILabel!
    
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let photoUrlString = post?.thumbnailUrl {
            let photoUrl = URL(string: photoUrlString)
            productImageView.sd_setImage(with: photoUrl)
        }
        
        titleLbl.text = (post?.title)!        
        priceLbl.text = "\((Functions.formatPrice(price: (post?.price)!)))円"
        shouldDoLbl.text = (post?.purchaserShouldDo)!
        shouldDoLbl.clipsToBounds = true

        if post?.purchaserShouldDo == Config.waitForShip {
            waitFor()

        } else if post?.purchaserShouldDo == Config.catchProduct {
            shouldDo()
        
        } else if post?.purchaserShouldDo == Config.waitForValue {
            waitFor()
        } else if post?.purchaserShouldDo == Config.buyFinish {
            shouldFinish()
        }
    }
    
    func waitFor() {
        shouldDoLbl.backgroundColor = UIColor.white
        shouldDoLbl.layer.borderWidth = 0.5
        shouldDoLbl.layer.borderColor = UIColor.red.cgColor
        shouldDoLbl.layer.cornerRadius = 5
        shouldDoLbl.font = UIFont.systemFont(ofSize: 13)
        shouldDoLbl.textColor = UIColor.red
    }
    
    func shouldDo() {
        shouldDoLbl.backgroundColor = UIColor.red
        shouldDoLbl.textColor = UIColor.white
        shouldDoLbl.font = UIFont.boldSystemFont(ofSize: 13)
        shouldDoLbl.layer.cornerRadius = 5
    }
    
    func shouldFinish() {
        shouldDoLbl.backgroundColor = UIColor.white
        shouldDoLbl.layer.borderWidth = 0.5
        shouldDoLbl.layer.borderColor = UIColor.darkGray.cgColor
        shouldDoLbl.layer.cornerRadius = 5
        shouldDoLbl.font = UIFont.systemFont(ofSize: 13)
        shouldDoLbl.textColor = UIColor.darkGray
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLbl.text = ""
        shouldDoLbl.text = ""
        priceLbl.text = ""
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
