//
//  SalesManagementViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class SalesManagementViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentUid = String()
    var totalAmount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.totalAmount = 0
        self.tableView.reloadData()
        Api.Charge.fetchChargeCount(userId: currentUid) { (chargeCount) in
            
            if chargeCount == 0 {
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
                
                if charge.type == Config.sold {
                    self.totalAmount = self.totalAmount + charge.price!
                } else {
                    self.totalAmount = self.totalAmount - charge.price!
                }
            }
            
            if count == chargeCount {
                //数字にカンマ,をつける
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                self.tableView.reloadData()
            }
        }
    }
}

extension SalesManagementViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "goToBankSelect_Seg", sender: nil)
            } else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "goToCharge_Seg", sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            return 30
        } else {
            return 44
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(section)
        if section == 2 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SalesManagementBalanceTableViewCell", for: indexPath) as! SalesManagementBalanceTableViewCell
            
            if self.totalAmount == 0 {
                cell.salesBalanceLbl.text = "--"
            } else {
                cell.salesBalanceLbl.text = Functions.formatPrice(price: self.totalAmount)
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDefultCellTableViewCell", for: indexPath) as! PostDefultCellTableViewCell
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyBalanceTableViewCell", for: indexPath) as! ApplyBalanceTableViewCell
            
            if indexPath.row == 0 {
                cell.applyBalanceLbl.text = "振込申請（現金で受取"
            } else if indexPath.row == 1 {
                cell.applyBalanceLbl.text = "入出金・チャージ履歴"
            }
            
            return cell
       
        default:
            return UITableViewCell()
        }
        
    }
}
