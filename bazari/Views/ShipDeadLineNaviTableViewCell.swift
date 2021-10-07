//
//  ShipDeadLineNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ShipDeadLineNaviTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paymentDateLbl: UILabel!
    @IBOutlet weak var shippedDateLbl: UILabel!
    
    @IBOutlet weak var shipDeadLineLbl: UILabel!
    
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let post = post {
            
            if let _ = paymentDateLbl {
                
                let timestamp = post.purchaseDateTimestamp
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                let dateString = dateFormatter.string(from: date)
                paymentDateLbl.text = "支払完了日: \(dateString)"
            }
            
            if let _ = shippedDateLbl {
                let timestamp = post.shippedDateTimestamp
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                let dateString = dateFormatter.string(from: date)
                shippedDateLbl.text = "発送通知日: \(dateString)"
            }
            
            if let _ = shipDeadLineLbl {
                let timestamp = post.purchaseDateTimestamp
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                var daysLater = TimeInterval()
                if post.shipDeadLine == Config.shipDatesList[0] {
                    daysLater = TimeInterval(2.days)
                } else if post.shipDeadLine == Config.shipDatesList[1] {
                    daysLater = TimeInterval(3.days)
                } else if post.shipDeadLine == Config.shipDatesList[2] {
                    daysLater = TimeInterval(7.days)
                }
                let resultDate = date.addingTimeInterval(daysLater)
                let dateString = dateFormatter.string(from: resultDate)
                shipDeadLineLbl.text = "発送期限: \(dateString)までに発送予定"
            }
            
        }
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let _ = paymentDateLbl {
            paymentDateLbl.text = ""
            if Config.isUnderIphoneSE {
                paymentDateLbl.font = UIFont.systemFont(ofSize: 12)
            }
        }
        
        if let _ = shippedDateLbl {
            shippedDateLbl.text = ""
            if Config.isUnderIphoneSE {
                shippedDateLbl.font = UIFont.systemFont(ofSize: 12)
            }
        }
        if let _ = shipDeadLineLbl {
            shipDeadLineLbl.text = ""
            if Config.isUnderIphoneSE {
                shipDeadLineLbl.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }
}
