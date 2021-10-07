//
//  ShipInfoTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/11.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol ShipInfoTableViewControllerDelegate {
    func shipType(shipType: String, shipTypeNum: Int)
}

class ShipInfoTableViewController: UITableViewController {

    var chosenShipType: String?
    var preShipPayment: String!
    var preShipTypeNum: Int!
    var shipTypeNum: Int!
    let shipPayments = ["送料込み (あなたが負担)","着払い (購入者が負担)"]
    
    let shipWays0 = ["レターパックライト","レターパックプラス","クリックポスト","宅急便コンパクト","ゆうパック元払い","ヤマト宅急便","ゆうパケット","ゆうメール元払い","スマートレター", "普通郵便","未定"]
    
    let shipWays1 = ["ゆうパック着払い", "ヤマト宅急便", "ゆうパケット","ゆうメール着払い","未定"]
    
    let shipDates = Config.shipDatesList
    
    let shipFromPrefectures = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県",
                               "茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県",
                               "新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県",
                               "静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県",
                               "奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県",
                               "徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県",
                               "熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    var shipData = [String]()
    
    var delegate: ShipInfoTableViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch preShipTypeNum {
        case 1:
            
            if preShipPayment == shipPayments[0] {
                shipData = shipWays0
            } else if preShipPayment == shipPayments[1] {
                shipData = shipWays1
            }
            shipTypeNum = 1
        case 2:
            shipData = shipDates
            shipTypeNum = 2
        case 3:
            shipData = shipFromPrefectures
            shipTypeNum = 3
        default:
            print("t")
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.shipType(shipType: shipData[indexPath.row], shipTypeNum: shipTypeNum)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shipData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShipInfoChooseTableViewCell", for: indexPath) as! ShipInfoChooseTableViewCell
        
        cell.titleLbl.text = shipData[indexPath.row]
        
        if let chosenShipType = chosenShipType {
            
            print(shipData[indexPath.row])
            print(chosenShipType)
            if shipData[indexPath.row] == chosenShipType {
                print(shipData[indexPath.row])
                print(chosenShipType)
                print(indexPath.row)
                cell.titleLbl.textColor = UIColor.red
                cell.accessoryType = .checkmark
            } else {
                cell.titleLbl.textColor = UIColor.black
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    
}
