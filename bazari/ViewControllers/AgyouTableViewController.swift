//
//  AgyouTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class AgyouTableViewController: UITableViewController {

    var bankSelectVC: BankSelectViewController?
    var preBank: String?

    var sectionRow = Int()
    let gojuon = [
        ["あ","い","う","え","お"],
        ["か","き","く","け","こ"],
        ["さ","し","す","せ","そ"],
        ["た","ち","つ","て","と"],
        ["な","に","ぬ","ね","の"],
        ["は","ひ","ふ","へ","ほ"],
        ["ま","み","む","め","も"],
        ["や","ゆ","よ"],
        ["ら","り","る","れ","ろ"],
        ["わ"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBankList_Seg" {
            let bankListVC = segue.destination as! BankListTableViewController
            let indexRow = sender as! Int
            
            switch sectionRow {
                //あ
            case 0:
                bankListVC.sectionRow = indexRow
                //か
            case 1:
                bankListVC.sectionRow = gojuon[0].count + indexRow
                //さ
            case 2:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count) + indexRow
                //た
            case 3:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count) + indexRow
                //な
            case 4:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count + gojuon[3].count) + indexRow
                //は
            case 5:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count + gojuon[3].count + gojuon[4].count) + indexRow
                //ま
            case 6:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count + gojuon[3].count + gojuon[4].count + gojuon[5].count) + indexRow
                //や
            case 7:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count + gojuon[3].count + gojuon[4].count + gojuon[5].count + gojuon[6].count) + indexRow
                //ら
            case 8:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count + gojuon[3].count + gojuon[4].count + gojuon[5].count + gojuon[6].count + gojuon[7].count) + indexRow
                //わ
            case 9:
                bankListVC.sectionRow = (gojuon[0].count + gojuon[1].count + gojuon[2].count + gojuon[3].count + gojuon[4].count + gojuon[5].count + gojuon[6].count + gojuon[7].count + gojuon[8].count) + indexRow

                
            default:
                print("t")
            }

            bankListVC.delegate = bankSelectVC
            bankListVC.bankSelectVC = bankSelectVC
            bankListVC.preBank = preBank
        }
    }

   
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gojuon[sectionRow].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath)

        cell.textLabel?.text = gojuon[sectionRow][indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToBankList_Seg", sender: indexPath.row)
    }
    
}
