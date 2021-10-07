//
//  BankSelectViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

class BankSelectViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedBank: String?
    var selectedBankType: String?
    var shitenCodeNum: Int?
    var kouzaBangouNum: Int?
    var inputShitenCodeNumCountFlg = false
    var inputKouzaBangouNumCountFlg = false
    var inputSeiFlg = false
    var inputMeiFlg = false
    var firstName: String?
    var lastName: String?
    var oneTimeFlg = false
    var currentUid = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        loadBankInfo()
    }
    
    func loadBankInfo() {
        SVProgressHUD.show()
        let currentUid = Api.User.CURRENT_USER?.uid
        Api.BankInfo.observeMyBank(userId: currentUid!) { (bankInfo) in
            SVProgressHUD.dismiss()
            if let bankInfo = bankInfo {
                
                self.selectedBank = bankInfo.bank
                self.selectedBankType = bankInfo.accountType
                self.shitenCodeNum = bankInfo.branchCode
                self.kouzaBangouNum = bankInfo.accountNumber
                self.inputShitenCodeNumCountFlg = true
                self.inputKouzaBangouNumCountFlg = true
                self.inputSeiFlg = true
                self.inputMeiFlg = true
                self.firstName = bankInfo.firstName
                self.lastName = bankInfo.lastName
                self.oneTimeFlg = true
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMainBank_Seg" {
            let mainBankVC = segue.destination as! MainBankTableViewController
            mainBankVC.delegate = self
            mainBankVC.preBank = selectedBank
            mainBankVC.bankSelectVC = self
        }
        
        if segue.identifier == "goToBankAccountType_Seg" {
            let bankVC = segue.destination as! HutsukouzaTableViewController
            bankVC.delegate = self
            bankVC.preType = selectedBankType
        }
        
        if segue.identifier == "transferAppliction_Seg" {
            let transferVC = segue.destination as! TransferApplictionTableViewController
            let params = sender as! [String: Any]
            let totalAmount: Int  = params["totalAmount"] as! Int
            let formattedNumber: String? = params["formattedNumber"] as? String
            transferVC.totalAmount = totalAmount
            transferVC.formattedNumber = formattedNumber
        }
        
        
    }
}

extension BankSelectViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        } else if section == 1 {
            return 4
        } else if section == 2 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 205
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "goToMainBank_Seg", sender: nil)
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "goToBankAccountType_Seg", sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankSelectTableViewCell", for: indexPath) as! BankSelectTableViewCell
            if indexPath.row == 0 {
                cell.bankLbl.text = "銀行"
                if let selectedBank = selectedBank {
                    cell.bankSelectLbl.text = selectedBank
                    cell.bankSelectLbl.textColor = UIColor.black
                }
                
            } else if indexPath.row == 1 {
                cell.bankLbl.text = "口座種別"
                if let selectedBankType = selectedBankType {
                    cell.bankSelectLbl.text = selectedBankType
                    cell.bankSelectLbl.textColor = UIColor.black
                }
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankAccountInputTableViewCell", for: indexPath) as! BankAccountInputTableViewCell
            
            cell.indexRow = indexPath.row
            cell.delegate = self
            if indexPath.row == 0 {
                cell.accountLbl.text = "支店コード"
                cell.accountTextField.placeholder = "数字3桁"
                cell.accountTextField.keyboardType = .numberPad
                
                if let shitenCodeNum = shitenCodeNum {
                    cell.accountTextField.text = "\(shitenCodeNum)"
                }
            } else if indexPath.row == 1 {
                cell.accountLbl.text = "口座番号"
                cell.accountTextField.placeholder = "数字7桁"
                cell.accountTextField.keyboardType = .numberPad
                
                if let kouzaBangouNum = self.kouzaBangouNum {
                    cell.accountTextField.text = "\(kouzaBangouNum)"
                }
            } else if indexPath.row == 2 {
                cell.accountLbl.text = "口座名義(セイ)"
                cell.accountTextField.placeholder = "全角カナ・英字"
                
                if let lastName = lastName {
                    cell.accountTextField.text = lastName
                }
            } else if indexPath.row == 3 {
                cell.accountLbl.text = "口座名義(メイ)"
                cell.accountTextField.placeholder = "全角カナ・英字"
                
                if let firstName = firstName {
                    cell.accountTextField.text = firstName
                }

            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankRegisterButtonTableViewCell", for: indexPath) as! BankRegisterButtonTableViewCell
            cell.delegate = self
            cell.bankRegisterButton.isEnabled = true
            return cell
        }
    }
}

extension BankSelectViewController: BankListTableViewControllerDelegate, HutsukouzaTableViewControllerDelegate, BankRegisterButtonTableViewCellDelegate, BankAccountInputTableViewCellDelegate {
    
    func inputTextCountFlg(flg: Bool, indexRow: Int, text: String?) {
        
        //(セイ)
        if indexRow == 2 {
            inputSeiFlg = flg
            lastName = text
        }
        //(メイ)
        else if indexRow == 3 {
            inputMeiFlg = flg
            firstName = text
        }
    }
    
    
    func inputNumCountFlg(flg: Bool, indexRow: Int) {
        
        //支店コード
        if indexRow == 0 {
            inputShitenCodeNumCountFlg = flg
        } else if indexRow == 1 {
            inputKouzaBangouNumCountFlg = flg
        }
    }
    
    
    func changeNum(inputNum: Int?,indexRow: Int) {
        
        if indexRow == 0 {
            shitenCodeNum = inputNum
        }
        
        if indexRow == 1 {
            kouzaBangouNum = inputNum
        }
    }
    
    
    func registerBankInfo() {
        

        if selectedBank == nil {
            ProgressHUD.showError("銀行を選択してください。")
            self.tableView.reloadData()
            return;
        }
        
        if selectedBankType == nil {
            ProgressHUD.showError("口座種別を選択してください。")
            self.tableView.reloadData()
            return;
        }
        
        if !inputShitenCodeNumCountFlg {
            ProgressHUD.showError("3ケタの支店コードを入力してください。")
            self.tableView.reloadData()
            return;
        }
        
        if !inputKouzaBangouNumCountFlg {
            ProgressHUD.showError("7ケタの口座番号を入力してください。")
            self.tableView.reloadData()
            return;
        }
        
        if !inputSeiFlg {
            ProgressHUD.showError("口座名義(セイ)を入力してください。")
            self.tableView.reloadData()
            return;
        }
        
        if !inputMeiFlg {
            ProgressHUD.showError("口座名義(メイ)を入力してください。")
            self.tableView.reloadData()
            return;
        }


        SVProgressHUD.show()
        Api.BankInfo.REF_MYBANK.child((Api.User.CURRENT_USER?.uid)!).setValue(["bank": selectedBank,"accountType": selectedBankType, "branchCode": shitenCodeNum, "accountNumber": kouzaBangouNum, "lastName": lastName,"firstName": firstName])
        
        Api.Charge.fetchChargeCount(userId: currentUid) { (chargeCount) in
            
            if chargeCount == 0 {
                let totalAmount: Int = 0
                let formattedNumber: String? = nil
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                self.performSegue(withIdentifier: "transferAppliction_Seg", sender: ["totalAmount": totalAmount, "formattedNumber": formattedNumber] as? [String: Any])
                return;
            } else {
                self.loadCharge(onSuccess: { (totalAmount, formattedNumber) in
                    self.tableView.reloadData()
                    self.performSegue(withIdentifier: "transferAppliction_Seg", sender: ["totalAmount": totalAmount, "formattedNumber": formattedNumber] as? [String: Any])
                })
            }
        }
        
        
        
        

    }
    
    func loadCharge(onSuccess:  @escaping (Int, String?) -> Void) {
        
        var totalAmount: Int = 0
        var formattedNumber: String? = nil
        var count = 0
        Api.Charge.observeMyCharge(userId: currentUid) { (charge, chargeCount) in
            
            
            count += 1
            if let charge = charge {
                
                if charge.type == Config.sold {
                    totalAmount = totalAmount + charge.price!
                } else {
                    totalAmount = totalAmount - charge.price!
                }
            }
            
            if count == chargeCount {
                SVProgressHUD.dismiss()
                //数字にカンマ,をつける
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                formattedNumber = numberFormatter.string(from: NSNumber(value: totalAmount))
                onSuccess(totalAmount, formattedNumber)
            }
        }
    }
    
    
    func kouzaType(type: String) {
        selectedBankType = type
    }
   
    func chooseBank(bankName: String) {
        selectedBank = bankName
    }
    
    
}
