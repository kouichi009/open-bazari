//
//  ShipInfoWithSubTitleTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/11.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol ShipInfoWithSubTitleTableViewControllerDelegate {
    func shipPaymentType(shipPayment: String, hasChanged : Bool)
}

class ShipInfoWithSubTitleTableViewController: UITableViewController {
    
    var preShipPayment: String?
    
    var delegate: ShipInfoWithSubTitleTableViewControllerDelegate?
    
    let shipPayments = ["送料込み (あなたが負担)","着払い (購入者が負担)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if preShipPayment == shipPayments[indexPath.row] {
            delegate?.shipPaymentType(shipPayment: shipPayments[indexPath.row], hasChanged: false)
        } else {
            delegate?.shipPaymentType(shipPayment: shipPayments[indexPath.row], hasChanged: true)
        }
        
        
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shipPayments.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipInfoWithSubTitleTableViewCell", for: indexPath) as! ShipInfoWithSubTitleTableViewCell
        
        cell.titleLbl.text = shipPayments[indexPath.row]
        
        if shipPayments[0] == shipPayments[indexPath.row] {
            cell.subTitleLbl.text = "送料を含めるため、購入者にとって親切です。"
            cell.recommendLbl.isHidden = false
        } else if shipPayments[1] == shipPayments[indexPath.row] {
            cell.subTitleLbl.text = "購入者が受け取りの時に、送料を支払います。"
            cell.recommendLbl.isHidden = true
        }
        
        if let preShipPayment = preShipPayment {
            
            if shipPayments[indexPath.row] == preShipPayment {
                cell.titleLbl.textColor = UIColor.red
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    
    
}
