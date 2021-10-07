//
//  BankAccountInputTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol BankAccountInputTableViewCellDelegate {
    func changeNum(inputNum: Int?, indexRow: Int)
    func inputNumCountFlg(flg: Bool, indexRow: Int)
    func inputTextCountFlg(flg: Bool, indexRow: Int, text: String?)
}

class BankAccountInputTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var accountLbl: UILabel!
    @IBOutlet weak var accountTextField: UITextField!
    
    var indexRow = Int()
    
    var delegate: BankAccountInputTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accountTextField.delegate = self
        accountTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("indexRow \(indexRow)")
        
        if indexRow >= 2 {
            return true
        }
        
        var maxLength = Int()
        if indexRow == 0 {
            maxLength = 3
        } else if indexRow == 1 {
            maxLength = 7
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        print("indexRow \(indexRow)")
        print("boolean \(newString.length <= maxLength)")
        print("newSt.length \(newString.length)")
        
        //支店コード
        if indexRow == 0 && newString.length >= 3 {
            delegate?.inputNumCountFlg(flg: true, indexRow: 0)
        } else if indexRow == 0 && newString.length < 3 {
            delegate?.inputNumCountFlg(flg: false, indexRow: 0)
        }
        
        //口座番号
        if indexRow == 1 && newString.length >= 7 {
            delegate?.inputNumCountFlg(flg: true, indexRow: 1)
        } else if indexRow == 1 && newString.length < 7 {
            delegate?.inputNumCountFlg(flg: false, indexRow: 1)
        }
        
        return newString.length <= maxLength
    }
    
    @objc func textFieldDidChange() {
        
        
        if indexRow >= 2 {
            if accountTextField.text == "" || accountTextField.text == nil {
                
                delegate?.inputTextCountFlg(flg: false, indexRow: indexRow, text: nil)
                return;
            } else {
                delegate?.inputTextCountFlg(flg: true, indexRow: indexRow, text: accountTextField.text)
                return;
            }
            
        } else {
            
            if accountTextField.text == "" || accountTextField.text == nil {
                
                delegate?.changeNum(inputNum: nil,indexRow: indexRow)
                return;
            }
            
            if let inputNum = accountTextField.text {
                let inputNumInteger = Int(inputNum)
                
                if inputNumInteger! < Config.minimumPrice {
                    delegate?.changeNum(inputNum: inputNumInteger,indexRow: indexRow)
                    return;
                }
                
                delegate?.changeNum(inputNum: inputNumInteger,indexRow: indexRow)
            }
        }
    }
}
