//
//  ProductStatusTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/11.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol ProductStatusTableViewControllerDelegate {
    func productStatusType(productStatus: String)
}

class ProductStatusTableViewController: UITableViewController {
    
    var preProductStatus: String?
    
    var delegate: ProductStatusTableViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.productStatusType(productStatus: Config.productStatuses[indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Config.productStatuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductStatusChooseTableViewCell", for: indexPath) as! ProductStatusChooseTableViewCell
        
        cell.statusLbl.text =
            Config.productStatuses[indexPath.row]
        cell.subTItleLbl.text =
        Config.productSubtitles[indexPath.row]
        
        if let preProductStatus = preProductStatus {
            
            if preProductStatus == Config.productStatuses[indexPath.row] {
                cell.statusLbl.textColor = UIColor.red
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    
}
