//
//  PageControlTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/13.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import CHIPageControl

class PageControlTableViewCell: UITableViewCell {

    @IBOutlet weak var pageControl: CHIPageControlAji!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
