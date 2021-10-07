//
//  CheckTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol CheckTableViewCellDelegate {
    func newPost()
    func draftPost()
}

class CheckTableViewCell: UITableViewCell {

    var delegate: CheckTableViewCellDelegate?
    
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var draftBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func post_TouchUpInside(_ sender: Any) {
        postBtn.isEnabled = false
        if let _ = draftBtn {
            draftBtn.isEnabled = false
        }
        delegate?.newPost()

    }
    
    @IBAction func draftPost_TouchUpInside(_ sender: Any) {
        postBtn.isEnabled = false
        if let _ = draftBtn {
            draftBtn.isEnabled = false
        }
        delegate?.draftPost()
    }
    
    

}
