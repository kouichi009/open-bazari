//
//  SettingTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    var settings = ["連絡先・住所の設定", "メールアドレス・パスワード","クレジットカードの登録・削除"]
    var unsubscribe = "退会する"
    
    var usermodel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            Api.User.observeUser(withId: currentUid) { (usermodel) in
                
                
                if let usermodel = usermodel {
                    
                    self.usermodel = usermodel
                    self.tableView.reloadData()
                }
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emailRegister_Seg" {
            let emailRegisterVC = segue.destination as! EmailSecondTableViewController
            
            emailRegisterVC.currentUid = (usermodel?.id)!
        }
        
        if segue.identifier == "displayAdd_Seg" {
            let displayVC = segue.destination as! Display_AddViewController
            displayVC.settingVC = self
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 || section == 2 || section == 3 {
            return 1
        } else {
            return settings.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 || indexPath.section == 2 {
            return;
        }
        
        if let _ = usermodel {
            if settings.count == 3 {
                
                if indexPath.section == 1 {
                    if indexPath.row == 0 {
                        self.performSegue(withIdentifier: "goToAddress_Seg", sender: nil)
                    } else if indexPath.row == 1 {
                        self.performSegue(withIdentifier: "emailRegister_Seg", sender: nil)
                    } else if indexPath.row == 2 {
                        self.performSegue(withIdentifier: "displayAdd_Seg", sender: nil)
                    }
                }
                
            } else if settings.count == 4 {
                
                if indexPath.section == 1 {
                    
                    if indexPath.row == 0 {
                        self.performSegue(withIdentifier: "goToAddress_Seg", sender: nil)
                        
                    } else if indexPath.row == 1 {
                        self.performSegue(withIdentifier: "emailRegister_Seg", sender: nil)
                    } else if indexPath.row == 2 {
                        self.performSegue(withIdentifier: "displayAdd_Seg", sender: nil)
                    }
                }
            }
            
            if indexPath.section == 3 {
                self.performSegue(withIdentifier: "deleteAccount_Seg", sender: nil)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath)
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            
            cell.textLabel?.text = settings[indexPath.row]
            
            return cell
            
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            
            cell.textLabel?.text = unsubscribe
            
            return cell
        }
        
        return UITableViewCell()
    }
}
