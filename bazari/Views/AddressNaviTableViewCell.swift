//
//  AddressNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/26.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class AddressNaviTableViewCell: UITableViewCell {
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var postalCodeLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var toPeopleLbl: UILabel!
    @IBOutlet weak var shipWayLbl: UILabel!
    @IBOutlet weak var shipDeadLineLbl: UILabel!
    // sellerだけ
    @IBOutlet weak var commisionPriceLbl: UILabel!
    @IBOutlet weak var earnMoneyLbl: UILabel!
    
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    var address: Address? {
        didSet {
            setUpAddress()
        }
    }
    
    func updateView() {
        
        if let _ = priceLbl {
            priceLbl.text = "\(Functions.formatPrice(price: (post?.price)!))円"
        }
        
        if let _ = shipWayLbl {
            shipWayLbl.text = "配送方法: "+(post?.shipWay)!
            shipDeadLineLbl.text = "発送期限: "+(post?.shipDeadLine)!
        }

        
        if let _ = commisionPriceLbl {
            let price = Double((post?.price)!)
            let commision: Int = Int(price * Config.commisionRate)
            commisionPriceLbl.text = "\(Functions.formatPrice(price: commision))円"
            let earn: Int = Int(Int(price) - commision)
            earnMoneyLbl.text = "\(Functions.formatPrice(price: earn))円"
        }

    }
    
    func setUpAddress() {
        
        if postalCodeLbl != nil {
            
            if let address = address {
                
                if let _ = address.building {
                    addressLbl.text = "\(address.prefecure!)\(address.city!)\(address.tyou!)\(address.building!)"
                } else {
                    addressLbl.text = "\(address.prefecure!)\(address.city!)\(address.tyou!)"
                }
                
                postalCodeLbl.text = "〒"+address.postalCode!
                toPeopleLbl.text = "\(address.seiKanji!)\(address.meiKanji!)"
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let _ = priceLbl {
            priceLbl.text = ""
        }
        
        if let _ = shipWayLbl {
            shipWayLbl.text = ""
            shipDeadLineLbl.text = ""
        }
        
        if let _ = commisionPriceLbl {
            commisionPriceLbl.text = ""
            earnMoneyLbl.text = ""
        }
        
        if let _ = postalCodeLbl {
            postalCodeLbl.text = ""
            addressLbl.text = ""
            toPeopleLbl.text = ""
            
            if Config.isUnderIphoneSE {
                postalCodeLbl.font = UIFont.systemFont(ofSize: 12)
                addressLbl.font = UIFont.systemFont(ofSize: 12)
                toPeopleLbl.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }

}
