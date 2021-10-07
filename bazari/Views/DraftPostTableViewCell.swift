//
//  DraftPostTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class DraftPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var draftLbl: UILabel!
    
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
        
        productTitleLbl.text = (post?.title)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        productTitleLbl.text = ""
        
        draftLbl.clipsToBounds = true
        draftLbl.backgroundColor = UIColor.white
        draftLbl.layer.borderWidth = 0.5
        draftLbl.layer.borderColor = UIColor.darkGray.cgColor
        draftLbl.layer.cornerRadius = 5
        draftLbl.textColor = UIColor.darkGray
        draftLbl.text = "下書き"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
