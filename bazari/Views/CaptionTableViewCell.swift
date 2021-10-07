//
//  CaptionTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import RegeributedTextView

class CaptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionTextView: RegeributedTextView!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        captionTextView.text = (post?.caption)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        captionTextView.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
