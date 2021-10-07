//
//  MainBankTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit


class MainBankTableViewController: UITableViewController {
    
    var preBank: String?
    var checkIndex = Int()
    let headers = ["主要金融機関","50音順"]
    let mainBanks = ["三菱ＵＦＪ銀行", "みずほ銀行","りそな銀行","埼玉りそな銀行","三井住友銀行","ジャパンネット銀行","楽天銀行","ゆうちょ銀行"]
    let orders = ["あ行","か行","さ行","た行","な行","は行","ま行","や行","ら行","わ行"]
    
    var delegate: BankListTableViewControllerDelegate?
    var bankSelectVC: BankSelectViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIndex = 0
        var checkFlg = false
        if let preBank = preBank {
            mainBanks.forEach { (mainBank) in

                if checkFlg {
                    return;
                }
                print(mainBank)
                print(preBank)
                if preBank == mainBank {
                    checkFlg = true
                    self.tableView.reloadData()
                    return;
                }
                checkIndex += 1
                
            }
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 16)
        header.textLabel?.textColor = UIColor.gray
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "gojuon_Seg" {
            
            let agyouVC = segue.destination as! AgyouTableViewController
            let sectionRow  = sender as! Int
            agyouVC.sectionRow = sectionRow
            agyouVC.bankSelectVC = bankSelectVC
            agyouVC.preBank = preBank
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0{
            return mainBanks.count
        } else {
            return orders.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath)
            
            cell.textLabel?.text = mainBanks[indexPath.row]
            
            if let _ = preBank {
                
                if checkIndex == indexPath.row {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = orders[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            delegate?.chooseBank(bankName: mainBanks[indexPath.row])
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: "gojuon_Seg", sender: indexPath.row)
        }
    }
}
