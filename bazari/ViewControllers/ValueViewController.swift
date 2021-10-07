//
//  ValueViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/15.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class ValueViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var userId = String()
    
    var purchaseValues = [Value]()
    var sellValues = [Value]()
    var allValues = [Value]()
    var selectedValues = [Value]()
    
    
    var segmentIndex = 0
    
    let refreshControl = UIRefreshControl()
    
    var usermodels = [UserModel]()
    var noMoreFlg = false
    var pullFlg = false

    var SUN = "sun"
    var CLOUD = "cloud"
    var RAIN = "rain"
    
    var SELL = "sell"
    var PURCHASE = "purchase"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchUserValues()
    }
    
    func fetchUserValues() {
        
        var count = 0
        var userCount = 0
        Api.Value.fetchUserValues(userId: userId) { (value, valueCount) in
            
            count += 1
            
            if let value = value {
                
                Api.User.observeUser(withId: value.from!, completion: { (usermodel) in
                    
                    userCount += 1
                    
                    if let usermodel = usermodel {
                        self.usermodels.append(usermodel)
                    }
                    
                    if valueCount == userCount {
                        self.tableView.reloadData()
                    }
                })
                
                
                
                self.allValues.append(value)
                
                switch value.type {
                    
                case "sell":
                    self.sellValues.append(value)
                case "purchase":
                    self.purchaseValues.append(value)
                default:
                    print("t")
                }
                
                if count == valueCount {
                    
                    switch self.segmentIndex {
                        
                    case 0:     //all
                        self.selectedValues = self.allValues
                    case 1:     //sell
                        self.selectedValues = self.sellValues
                    case 2:     //purchase
                        self.selectedValues = self.purchaseValues
                    default:
                        print("t")
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    func reload() {
        
        initiazlize()
        
        switch segmentIndex {
        case 0:
            self.selectedValues = self.allValues

        case 1:
            self.selectedValues = self.sellValues

        case 2:
            self.selectedValues = self.purchaseValues

        default:
            print("t")
        }
        self.tableView.reloadData()
    }
    
    func initiazlize() {
        selectedValues.removeAll()
        self.tableView.reloadData()
    }
    
    
    
    @IBAction func segment_TouchUpInside(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: //all
            segmentIndex = 0
            
        case 1: //sell
            segmentIndex = 1
            
        case 2: //purchase
            segmentIndex = 2
            
        default:
            print("該当無し")
        }
        reload()
        
    }
}

extension ValueViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 44
        } else if indexPath.section == 1 {
            return UITableViewAutomaticDimension
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if selectedValues.count == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        } else {
            print(selectedValues.count)
            return selectedValues.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueNumTableViewCell", for: indexPath) as! ValueNumTableViewCell
            
            switch indexPath.row {
            case 0:
                cell.valueImageView.image = #imageLiteral(resourceName: "Sun")
                cell.valueLbl.text = "よい評価"
                var sunCount = 0
                
                switch segmentIndex {
                case 0:
                    
                    for allValue in allValues {
                        
                        if allValue.valueStatus == SUN  {
                            sunCount += 1
                        }
                    }
                    
                    
                case 1:
                    
                    for sellValue in sellValues {
                        
                        if sellValue.valueStatus == SUN {
                            sunCount += 1
                        }
                    }
                    
                case 2:
                    for purchaseValue in purchaseValues {
                        
                        if purchaseValue.valueStatus == SUN && purchaseValue.type == PURCHASE {
                            sunCount += 1
                        }
                    }
                    
                default:
                    print("t")
                }
                
                cell.valueCountLbl.text = "\(sunCount)件"
                
                
                
            case 1:
                cell.valueImageView.image = #imageLiteral(resourceName: "Cloud")
                cell.valueLbl.text = "ふつうの評価"
                var cloudCount = 0
                
                switch segmentIndex {
                case 0:
                    
                    for allValue in allValues {
                        
                        if allValue.valueStatus == CLOUD {
                            cloudCount += 1
                        }
                    }
                    
                case 1:
                    
                    for sellValue in sellValues {
                        
                        if sellValue.valueStatus == CLOUD {
                            cloudCount += 1
                        }
                    }
                    
                case 2:
                    for purchaseValue in purchaseValues {
                        
                        if purchaseValue.valueStatus == CLOUD {
                            cloudCount += 1
                        }
                    }
                    
                default:
                    print("t")
                }
                
                cell.valueCountLbl.text = "\(cloudCount)件"
                
            case 2:
                cell.valueImageView.image = #imageLiteral(resourceName: "Rain")
                cell.valueLbl.text = "わるい評価"
                var rainCount = 0
                
                switch segmentIndex {
                case 0:
                    
                    for allValue in allValues {
                        
                        if allValue.valueStatus == RAIN {
                            rainCount += 1
                        }
                    }
                    
                case 1:
                    
                    for sellValue in sellValues {
                        
                        if sellValue.valueStatus == RAIN {
                            rainCount += 1
                        }
                    }
                    
                case 2:
                    for purchaseValue in purchaseValues {
                        
                        if purchaseValue.valueStatus == RAIN {
                            rainCount += 1
                        }
                    }
                    
                default:
                    print("t")
                }
                
                cell.valueCountLbl.text = "\(rainCount)件"
                
            default:
                print("t")
            }
            
            
            
            
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCommentTableViewCell", for: indexPath) as! ValueCommentTableViewCell
            
            cell.value = self.selectedValues[indexPath.row]
            
            for usermodel in usermodels {
                if usermodel.id ==
                    self.selectedValues[indexPath.row].from {
                    cell.usermodel = usermodel
                    break;
                }
            }
            return cell
        }
        
        return UITableViewCell()
    }
}
