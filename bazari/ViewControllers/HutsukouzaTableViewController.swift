//
//  HutsukouzaTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol HutsukouzaTableViewControllerDelegate {
    func kouzaType(type: String)
}

class HutsukouzaTableViewController: UITableViewController {
    
    var preType: String?
    var checkIndex = Int()

    var delegate: HutsukouzaTableViewControllerDelegate?
    let kouzaTypes = ["普通","当座","貯蓄"]

    override func viewDidLoad() {
        super.viewDidLoad()

       self.title = "口座種別の選択"
        
        checkIndex = 0
        var checkFlg = false
        if let preType = preType {
            kouzaTypes.forEach { (type) in
                
                if checkFlg {
                    return;
                }
                if preType == type {
                    checkFlg = true
                    self.tableView.reloadData()
                    return;
                }
                checkIndex += 1
                
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath)
        
        cell.textLabel?.text = kouzaTypes[indexPath.row]
        
        if let _ = preType {
            
            if checkIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.kouzaType(type: kouzaTypes[indexPath.row])
        _ = self.navigationController?.popViewController(animated: true)

    }
    

  

}
