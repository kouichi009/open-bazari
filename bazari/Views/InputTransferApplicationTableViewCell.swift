//
//  InputTransferApplicationTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/04.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol InputTransferApplicationTableViewCellDelegate {
    func applyTransfer(price: Int?)
}

class InputTransferApplicationTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var currentSalesPriceLbl: UILabel!
    @IBOutlet weak var inputPriceTextField: UITextField!
    @IBOutlet weak var leftSalesLbl: UILabel!
    @IBOutlet weak var bankTransBtn: UIButton!
    
    
    var delegate: InputTransferApplicationTableViewCellDelegate?
    
    var totalAmount: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentSalesPriceLbl.text = ""
        inputPriceTextField.delegate = self
        leftSalesLbl.text = "--円"
        
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("donePushed")
        
        show { (price) in
            print(price)
        }
    }
    
    @IBAction func apply_TouchUpInside(_ sender: Any) {
        
        bankTransBtn.isEnabled = false
        show { (price) in
           
            //エラーだった場合、再びボタンを押せるようにする
            if price == nil {
                self.bankTransBtn.isEnabled = true
            } else {
                self.delegate?.applyTransfer(price: price)
            }
        }
    }
    
    func show(completion: @escaping (Int?) -> Void) {
        if let _ = inputPriceTextField.text {
            let tex = inputPriceTextField.text!
            for character in tex {

                if character == "0" {
                    inputPriceTextField.text = ""
                    leftSalesLbl.text = "--円"
                    ProgressHUD.showError("エラー")
                    completion(nil)
                    return;
                }
                break;
            }


            if inputPriceTextField.text == "" || inputPriceTextField.text == nil {
                leftSalesLbl.text = "--円"
                ProgressHUD.showError("振込申請金額を入力してください。")
                completion(nil)

                return;
            }

            if let inputPrice = inputPriceTextField.text {
                let inputPriceInteger = Int(inputPrice)

                if inputPriceInteger! < Config.minimumTransferApplyPrice {
                    inputPriceTextField.text = ""
                    leftSalesLbl.text = "--円"
                    ProgressHUD.showError("振込申請は\(Functions.formatPrice(price: Config.minimumTransferApplyPrice))円以上からになります。")
                    completion(nil)

                    return;
                } else if inputPriceInteger! > Config.maximumTransferApplyPrice {
                    inputPriceTextField.text = ""
                    leftSalesLbl.text = "--円"
                    ProgressHUD.showError("振込申請の上限は\(Functions.formatPrice(price: Config.maximumTransferApplyPrice))円になります。")
                    completion(nil)
                    
                    return;
                }

                if let totalAmount = totalAmount {

                    if totalAmount < inputPriceInteger! {
                        inputPriceTextField.text = ""
                        leftSalesLbl.text = "--円"
                        ProgressHUD.showError("残高不足です。")
                        completion(nil)

                        return;
                    }

                    leftSalesLbl.text = Functions.formatPrice(price: totalAmount - inputPriceInteger!)+"円"
                    completion(inputPriceInteger!)
                }
            }
        }
    }
}
