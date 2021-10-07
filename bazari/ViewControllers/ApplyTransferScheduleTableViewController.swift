//
//  ApplyTransferScheduleTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/10/07.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ApplyTransferScheduleTableViewController: UITableViewController {
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var lbl7: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Config.isUnderIphoneSE {
            lbl1.font = UIFont.systemFont(ofSize: 11)
            lbl2.font = UIFont.systemFont(ofSize: 11)
            lbl4.font = UIFont.systemFont(ofSize: 11)
            lbl5.font = UIFont.systemFont(ofSize: 11)
            lbl6.font = UIFont.systemFont(ofSize: 11)
            lbl7.font = UIFont.systemFont(ofSize: 11)
        }
        
        lbl7.text = "振込申請で一月あたりに申請できる金額は、\(Functions.formatPrice(price: Config.minimumTransferApplyPrice))円〜\(Functions.formatPrice(price: Config.maximumTransferApplyPrice))円です。"
    }

}
