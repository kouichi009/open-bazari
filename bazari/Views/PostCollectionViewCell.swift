//
//  PostCollectionViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//
import UIKit
import SDWebImage


class PostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var soldOutImageView: UIImageView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var rightSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSideConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.thumbnailUrl {
            let photoUrl = URL(string: photoUrlString)
            photo.sd_setImage(with: photoUrl)
        }
        
        
        if let _ = soldOutImageView {
            
            if post?.transactionStatus == Config.transaction || post?.transactionStatus == Config.sold {
                soldOutImageView.isHidden = false
                soldOutImageView.image = #imageLiteral(resourceName: "soldout")
            } else {
                soldOutImageView.isHidden = true
            }
        }
        
        titleLbl.text = (post?.title)!
        
        if (post?.transactionStatus)! == Config.sell  {
            priceLbl.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            let newPrice = Functions.formatPrice(price: (post?.price)!)
            priceLbl.textColor = UIColor.black
            priceLbl.text = "¥\(newPrice)"
        } else {
            priceLbl.textColor = UIColor.red
            priceLbl.text = "SOLDOUT"
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //    soldOutImageView.isHidden = true
        photo.isUserInteractionEnabled = false
        
    }
    
}
