//
//  Name_AddressViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class Name_AddressViewController: UIViewController {
    
    
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var uiViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    var seiKanji: String?
    var meiKanji: String?
    var seiKana: String?
    var meiKana: String?
    var phoneNumber: String?
    var postalCode: String?
    var prefecture: String?
    var city: String?
    var tyou: String?
    var building: String?
    
    let names = ["姓（全角）", "名（全角）", "セイ（全角カナ）", "メイ（全角カナ）", "電話番号"]
    let namesPlaceholder = ["姓", "名", "セイ", "メイ", "ハイフンなしで入力"]
    let address = ["郵便番号","都道府県","市区町村","町名番地","建物名"]
    let addressPlaceholder = ["ハイフンなしで入力","選択してください","◯◯市、◯◯区","△△町××番地","⬜︎⬜︎マンション123"]
    
    let headers = ["取引に必要な情報","配送先住所"]
    
    var currentUid = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        uiView.backgroundColor = UIColor(red: 255/255, green: 238/255, blue: 199/255, alpha: 1)
        uiView.layer.borderWidth = 2
        uiView.layer.borderColor = UIColor(red: 255/255, green: 140/255, blue: 40/255, alpha: 1).cgColor
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        loadMyAddress()
    }
    
    
    func loadMyAddress() {
        Api.Address.observeAddress(userId: currentUid) { (address) in
            
            if let address = address {
                
                self.seiKanji = address.seiKanji
                self.meiKanji = address.meiKanji
                self.seiKana = address.seiKana
                self.meiKana = address.meiKana
                self.phoneNumber = address.phoneNumber
                self.postalCode = address.postalCode
                self.prefecture = address.prefecure
                self.city = address.city
                self.tyou = address.tyou
                self.building = address.building
                            
                if let _ = address.seiKanji {
                    self.uiViewHeightConstraint.constant = 0
                    self.uiView.isHidden = true
                }
               
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    @IBAction func saveData_TouchUpInside(_ sender: Any) {
        

        guard let _ = seiKanji else {
            ProgressHUD.showError(names[0]+"を入力してください。")
            return}
        
        guard let _ = meiKanji else {
            ProgressHUD.showError(names[1]+"を入力してください。")
            return}
        
        guard let _ = seiKana else {
            ProgressHUD.showError(names[2]+"を入力してください。")
            return}

        guard let _ = meiKana else {
            ProgressHUD.showError(names[3]+"を入力してください。")
            return}
        
        guard let _ = phoneNumber else {
            ProgressHUD.showError(names[4]+"を入力してください。")
            return}
        
        guard let _ = postalCode else {
            ProgressHUD.showError(address[0]+"を入力してください。")
            return}

        guard let _ = prefecture else {
            ProgressHUD.showError(address[1]+"を入力してください。")
            return}
        
        guard let _ = city else {
            ProgressHUD.showError(address[2]+"を入力してください。")
            return}

        guard let _ = tyou else {
            ProgressHUD.showError(address[3]+"を入力してください。")
            return}


        SVProgressHUD.show()
        Api.Address.REF_ADDRESS.child(currentUid).setValue(["seiKanji": seiKanji,"meiKanji": meiKanji, "seiKana": seiKana, "meiKana": meiKana, "phoneNumber": phoneNumber, "postalCode": postalCode, "prefecture": prefecture, "city": city, "tyou": tyou, "building": building], withCompletionBlock: { (error, ref) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        })
        
        
    }
}

extension Name_AddressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.gray
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath) as! Name_AddressTableViewCell
                cell.textField1.placeholder = namesPlaceholder[indexPath.row]
                cell.label1.text = names[indexPath.row]
                cell.delegate = self
                if indexPath.row == 4 {
                    cell.textField1.keyboardType = .numberPad
                }
                cell.section = indexPath.section
                cell.row = indexPath.row
                
                
                var tex = String()
                switch indexPath.row {
                case 0:
                    if let seiKanji = seiKanji {
                       tex = seiKanji
                    }
                case 1:
                    if let meiKanji = meiKanji {
                        tex = meiKanji
                    }

                case 2:
                    if let seiKana = seiKana {
                        tex = seiKana
                    }
                case 3:
                    if let meiKana = meiKana {
                        tex = meiKana
                    }
                case 4:
                    if let phoneNumber = phoneNumber {
                        tex = phoneNumber
                    }
                default:
                    print("t")
                }
                
                cell.textField1.text = tex
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! Name_AddressTableViewCell
                cell.delegate = self
                if indexPath.row == 0 {
                    cell.textField1.keyboardType = .numberPad
                }
                    
                else if indexPath.row == 1 {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapTextField))
                    cell.textField1.addGestureRecognizer(tapGesture)
                    cell.textField1.isUserInteractionEnabled = true
                    
                    if let prefecture = self.prefecture {
                        cell.textField1.text = prefecture
                    }
                }
                cell.textField1.placeholder = addressPlaceholder[indexPath.row]
                cell.label1.text = address[indexPath.row]
                
                cell.section = indexPath.section
                cell.row = indexPath.row
                
                var tex = String()
                switch indexPath.row {
                case 0:
                    if let postalCode = postalCode {
                        tex = postalCode
                    }
                case 1:
                    if let prefecture = prefecture {
                        tex = prefecture
                    }
                    
                case 2:
                    if let city = city {
                        tex = city
                    }
                case 3:
                    if let tyou = tyou {
                        tex = tyou
                    }
                case 4:
                    if let building = building {
                        tex = building
                    }
                default:
                    print("t")
                }
                
                cell.textField1.text = tex
                
                return cell
            }
        

    }
    
    @objc func tapTextField() {
        print("tapGesture")
        self.performSegue(withIdentifier: "prefecture_Seg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "prefecture_Seg" {
            let addressVC = segue.destination as! AddressPrefectureTableViewController
            addressVC.delegate = self
        }
    }
    
    
}

extension Name_AddressViewController: AddressPrefectureTableViewControllerDelegate, Name_AddressTableViewCellDelegate {
    
    func inputText(text: String?, type: String) {
        
        switch type {
        case "00":
            self.seiKanji = text
        case "01":
            self.meiKanji = text
        case "02":
            self.seiKana = text
        case "03":
            self.meiKana = text
        case "04":
            self.phoneNumber = text
        case "10":
            self.postalCode = text
        case "12":
            self.city = text
        case "13":
            self.tyou = text
        case "14":
            self.building = text

        default:
            print("t")
        }
    }
    
    func getPrefecture(prefecture: String) {
        self.prefecture = prefecture
    }
}
