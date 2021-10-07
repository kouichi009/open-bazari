//
//  KeywordTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
protocol KeywordTableViewCellDelegate {
    func deleteKeyword(keyword: String?)
}

class KeywordTableViewCell: UITableViewCell {

    
    @IBOutlet weak var keywordLbl: UILabel!
    @IBOutlet weak var closeImageView: UIImageView!
    var delegate: KeywordTableViewCellDelegate?
    
    var searchKeyword: String? {
        didSet {
            updateView(type: "searchKeyword")
        }
    }
    
    var titleStr: String? {
        didSet {
            updateView(type: "title")
        }
    }
    
    func updateView(type: String) {
        
        if type == "searchKeyword" {
            keywordLbl.text = searchKeyword
        } else if type == "title" {
            keywordLbl.text = titleStr

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleClose))
        closeImageView.addGestureRecognizer(tapGesture)
        closeImageView.isUserInteractionEnabled = true
    }
    
    @objc func handleClose() {
        
        delegate?.deleteKeyword(keyword: searchKeyword)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
