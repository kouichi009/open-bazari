//
//  PaymentTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking
import SVProgressHUD

protocol PaymentTableViewCellDelegate {
    func payButtonTouch()
    func goToAddCardVC()
}

class PaymentTableViewCell: UITableViewCell {
    
    var price: Int?
    var selectedCard: Card?
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var creditCardLbl: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!
    
    
    var delegate: PaymentTableViewCellDelegate?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        priceLbl.text = ("\(Config.yen)\((post?.price)!)")
        price = post?.price
        
        if let card = selectedCard {
            creditCardLbl.textColor = UIColor.black
            creditCardLbl.font = UIFont.systemFont(ofSize: 12)
            setCard(card: card)
        } else {
            creditCardLbl.text = "未登録"
            creditCardLbl.font = UIFont.systemFont(ofSize: 17)
            creditCardLbl.textColor = UIColor.red
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToAddCardVC))
        creditCardView.addGestureRecognizer(tapGesture)
        creditCardView.isUserInteractionEnabled = true
        
        priceLbl.text = ""
        creditCardLbl.text = ""
    }
    
    @objc func goToAddCardVC() {
        delegate?.goToAddCardVC()
    }
    
    func setCard(card: Card) {
        let eightMoji: String = card.id!
        let start4Moji = eightMoji.prefix(4)
        let last4Moji = eightMoji.suffix(4)
        let laststart2Moji = last4Moji.prefix(2)
        let lastlast2Moji = last4Moji.suffix(2)
        
        let zenhan = "************ " + start4Moji + "  "
        let kouhan = laststart2Moji + "/" + lastlast2Moji + ""
        let cardInfoMoji = zenhan + kouhan
        
        creditCardLbl.text = cardInfoMoji
    }
    
    @IBAction func pay_TouchUpInside(_ sender: Any) {
        paymentBtn.isEnabled = false
        delegate?.payButtonTouch()
    }
    
}
