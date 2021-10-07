//
//  ChargeTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/05.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class ChargeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currentUid = String()
    var charges = [Charge]()
    
    @IBOutlet weak var totalAmountLbl: UILabel!
    var totalAmount = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        totalAmountLbl.text = "--"
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        Api.Charge.fetchChargeCount(userId: currentUid) { (chargeCount) in
            
            if chargeCount == 0 {
                self.totalAmountLbl.text = "0円"
                return;
            } else {
                self.loadCharge()
            }
        }
    }
    
    func loadCharge() {
        var count = 0
        Api.Charge.observeMyCharge(userId: currentUid) { (charge, chargeCount) in
            
            count += 1
            if let charge = charge {
                self.charges.append(charge)
                
                if charge.type == Config.sold {
                    self.totalAmount = self.totalAmount + charge.price!
                } else {
                    self.totalAmount = self.totalAmount - charge.price!
                }
            }
            
            if count == chargeCount {
                self.totalAmountLbl.text = "\(Functions.formatPrice(price: self.totalAmount))円"
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "入出金履歴"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 16)
        header.textLabel?.textColor = UIColor.gray
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return charges.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargeTableViewCell", for: indexPath) as! ChargeTableViewCell
        
        if charges.count != 0 {
            
            cell.titleLbl.text = charges[indexPath.row].titleStr
            if charges[indexPath.row].type == Config.sold {
                cell.statusLbl.text = "売却済"
                cell.priceLbl.textColor = UIColor.green
                cell.priceLbl.text = "+\(Functions.formatPrice(price: charges[indexPath.row].price!))円"
            } else if charges[indexPath.row].type == Config.application  {
                cell.statusLbl.text = "申請済"
                cell.priceLbl.textColor = UIColor.red
                cell.priceLbl.text = "-\(Functions.formatPrice(price: charges[indexPath.row].price!))円"
                
            }

            let timestamp = charges[indexPath.row].timestamp
            let dateStr = dateString(timestamp: timestamp!)
            cell.dateLbl.text = dateStr
            return cell
        }
        
        return UITableViewCell()
    }
    
    func dateString(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        return dateString
        
    }
}
