//
//  NaviFinalTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/29.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class NaviFinalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var finalTransactionLbl: UILabel!
    
    @IBOutlet weak var valueImageView: UIImageView!
    
    @IBOutlet weak var valueLbl: UILabel!
    
    @IBOutlet weak var valueCommentLbl: UILabel!
    
    
    
    var post: Post? {
        didSet {
            updatePost()
        }
    }
    
    var value: Value? {
        didSet {
            updateView()
        }
    }
    
    func updatePost() {
        
        if let post = post {
            
            let timestamp = post.timestamp
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp!))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            let dateString = dateFormatter.string(from: date)
            finalTransactionLbl.text = "取引完了日: \(dateString)"
        }
    }
    func updateView() {
        
        if let value = value {
            
            
            if value.valueStatus == "sun" {
                valueImageView.image = #imageLiteral(resourceName: "Sun")
                valueLbl.text = "よい評価"
            } else if value.valueStatus == "cloud" {
                valueImageView.image = #imageLiteral(resourceName: "Cloud")
                valueLbl.text = "ふつうの評価"
            } else if value.valueStatus == "rain" {
                valueImageView.image = #imageLiteral(resourceName: "Rain")
                valueLbl.text = "わるい評価"
            }
            let charReplace = "\n"
            let comment = value.valueComment?.replacingOccurrences(of: charReplace, with: "")
            valueCommentLbl.text = comment
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
