//
//  ShipDeadLineSellerNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol ShipDeadLineSellerNaviTableViewCellDelegate {
    func back()
}

class ShipDeadLineSellerNaviTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shipDeadLineDateLbl: UILabel!
    @IBOutlet weak var daysLeftLbl: UILabel!
    @IBOutlet weak var shipWayLbl: UILabel!
    
    
    @IBOutlet weak var shipAlertBtn: UIButton!
    @IBOutlet weak var shippedDateLbl: UILabel!
    
    var neverCallAgainFlg = false
    
    var delegate: ShipDeadLineSellerNaviTableViewCellDelegate?
    var deadLineDate = NSDate()
    var timerOffFlg = false
    var timer = Timer()
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        shipDeadLineDate()

    }
    
    func shipDeadLineDate() {
        
        if let _ = post?.purchaseDateTimestamp {
            
            if timerOffFlg {
                timer.invalidate()
            }
            
            if let _ = shipWayLbl {
                shipWayLbl.text = post?.shipWay
            }
            
            if !neverCallAgainFlg {
                neverCallAgainFlg = true
                let timestamp = post?.purchaseDateTimestamp
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                var daysLater = TimeInterval()
                
                if post?.shipDeadLine == Config.shipDatesList[0] {
                    daysLater = TimeInterval(2.days)
                } else if post?.shipDeadLine == Config.shipDatesList[1] {
                    daysLater = TimeInterval(3.days)
                } else if post?.shipDeadLine == Config.shipDatesList[2] {
                    daysLater = TimeInterval(7.days)
                }
                
                let resultDate = date.addingTimeInterval(daysLater)
                let dateString = dateFormatter.string(from: resultDate)
                
                if let _ = shipDeadLineDateLbl {
                    shipDeadLineDateLbl.text = dateString
                    remainDeadLine(resultDate: resultDate, dateFormatter: dateFormatter)
                }
            }
            
            if let _ = shippedDateLbl {
                let timestamp = post?.shippedDateTimestamp
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                let dateString = dateFormatter.string(from: date)
                shippedDateLbl.text = "発送通知日: \(dateString)"
            }
        }
    }
    
    func remainDeadLine(resultDate: Date, dateFormatter: DateFormatter) {

        let dateString = dateFormatter.string(from: resultDate)
        deadLineDate = dateFormatter.date(from: dateString)! as NSDate
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTime() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let diffDateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: deadLineDate as Date)
        
        let countdown = "残り\(diffDateComponents.day ?? 0)日\(diffDateComponents.hour ?? 0)時間\(diffDateComponents.minute ?? 0)分\(diffDateComponents.second ?? 0)秒"
        
        print(countdown)
        if let minute = diffDateComponents.minute {
            if minute < -1 {
                daysLeftLbl.textColor = UIColor.red
                daysLeftLbl.text = "期限がすぎています。今すぐ発送してください。"
            } else {
                daysLeftLbl.text = countdown
            }
        }
    }
    
    @IBAction func shipAlert_TouchUpInside(_ sender: Any) {
        
        shipAlertBtn.isEnabled = false
            delegate?.back()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if let _ = shipDeadLineDateLbl {
            shipDeadLineDateLbl.text = ""
        }
        
        if let _ = daysLeftLbl {
            daysLeftLbl.text = ""
        }
        
        if let _ = shipWayLbl {
            shipWayLbl.text = ""
        }
        
        if let _ = shippedDateLbl {
            shippedDateLbl.text = ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
