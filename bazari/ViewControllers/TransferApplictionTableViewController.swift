//
//  TransferApplictionTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/04.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class TransferApplictionTableViewController: UITableViewController {
    
    var currentUid = String()
    var totalAmount = 0
    var formattedNumber: String?
    
    var bankAccountNumber: Int?
    var bankAccountType: String?
    var bank: String?
    var branchCode: Int?
    var firstName: String?
    var lastName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        
        Api.BankInfo.observeMyBank(userId: currentUid) { (bankInfo) in
            self.bankAccountNumber = bankInfo?.accountNumber
            self.bankAccountType = bankInfo?.accountType
            self.bank = bankInfo?.bank
            self.branchCode = bankInfo?.branchCode
            self.firstName = bankInfo?.firstName
            self.lastName = bankInfo?.lastName
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 188
        case 1:
            return 30
        case 2:
            return 201
        case 3:
            return 30
        case 4:
            return 44
        default:
            print("t")
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            self.performSegue(withIdentifier: "DetailTransferExplain_Seg", sender: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransferApplicationExplainTableViewCell", for: indexPath) as! TransferApplicationExplainTableViewCell
            cell.delegate = self
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell0", for: indexPath)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputTransferApplicationTableViewCell", for: indexPath) as! InputTransferApplicationTableViewCell
            
            cell.delegate = self
            cell.totalAmount = self.totalAmount
            if let formattedNumber = formattedNumber {
                cell.currentSalesPriceLbl.text = formattedNumber+"円"
            } else {
                cell.currentSalesPriceLbl.text = "0円"
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell1", for: indexPath)
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)
            return cell
            
        default:
            print("t")
        }
        
        return UITableViewCell()
        
    }
    
    func getToday(format:String = "yyyy/MM/dd HH:mm:ss") -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: now as! Date)
    }
    
    func showAlert(price: Int?) {
        
        let alert = UIAlertController(title: "振込申請していいですか？", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler: {(alert: UIAlertAction!) in
            ProgressHUD.showError("キャンセルしました。")
            _ = self.navigationController?.popViewController(animated: true)

        })
        let OKAction = UIAlertAction(title: "はい", style: .default, handler: {(alert: UIAlertAction!) in
            self.applyTransfer2(price: price)

        })
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func applyTransfer2(price: Int?) {
        
        if let _ = price {
            let priceForCharge = price!
            let timestamp = Int(Date().timeIntervalSince1970)
            guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
           
            
            let today: String = getToday(format: "yyyy-MM-dd")
            let dates: [String] = today.components(separatedBy: "-")
            var year: String = dates[0]
            var yearInt: Int = Int(year)!
            var month: String = dates[1]
            var monthInt: Int = Int(month)!
            
            monthInt += 1
            
            if monthInt > 12 {
                yearInt += 1
                monthInt = 1
                year = String(yearInt)
                
            }
            
            month = String(monthInt)
            let month_date = "\(month)-15"
            
            Api.BankTransDate.observeBankTrasDate(year: year, month_date: month_date, uid: currentUid) { (bankTrasDate) in
                
                // newPrice(bankTransferDatesノードのprice)
                // 今月分の申請が初回であれば、if let bankTransDateの中は読まずに、newPriceの金額がそのままノードにかかれる。
                var newPrice = priceForCharge
                
                //今月分の申請が2回目以降であれば、
                if let bankTrasDate = bankTrasDate {
                    
                    //oldPrice(bankTransferDatesノードのpriceから引っ張って来たデータ)
                    let oldPrice = bankTrasDate.price
                    // 今回チャージする金額を上乗せて、newPriceに代入
                    newPrice = oldPrice! + priceForCharge
                    
                    if newPrice > Config.maximumTransferApplyPrice {
                        self.showAlert(title:  "一月あたりの申請金額の上限を超えています。", message:  "合計\(Functions.formatPrice(price: Config.maximumTransferApplyPrice))円を超える申請はできません。次月に再度申請してください。")
                        return;
                    }
                    
                }
                
               
                //bankTransferDatesノード
                let ref = Api.BankTransDate.REF_BANK_TRANSFER_DATES.child(year).child(month_date).child(currentUid)
                let dict = ["bank": ["accountNumber": self.bankAccountNumber, "accountType": self.bankAccountType, "bank": self.bank, "branchCode": self.branchCode, "firstName": self.firstName, "lastName": self.lastName], "price": newPrice, "applyDate": today] as? [String: Any]
                
                ref.setValue(dict!, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                    } else {
                        //myChargeノード
                        let autoKey = Api.Charge.REF_MYCHARGE.child(currentUid).childByAutoId().key
                        Api.Charge.REF_MYCHARGE.child(currentUid).child(autoKey!).setValue(["timestamp": timestamp, "title": "振込申請", "price": priceForCharge, "type": Config.application])
                        self.showAlert(title: "振込申請完了", message: "")
                    }
                })
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            _ = self.navigationController?.popViewController(animated: true)
        })
      
            alert.addAction(OKAction)
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension TransferApplictionTableViewController: TransferApplicationExplainTableViewCellDelegate, InputTransferApplicationTableViewCellDelegate {
    
    func applyTransfer(price: Int?) {
        
        showAlert(price: price)
        
    }
    
    func goToDetailTransfer() {
        
        self.performSegue(withIdentifier: "DetailTransferExplain_Seg", sender: nil)
    }
}
