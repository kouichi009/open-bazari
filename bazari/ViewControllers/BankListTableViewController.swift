//
//  BankListTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol BankListTableViewControllerDelegate {
    func chooseBank(bankName: String)
}

class BankListTableViewController: UITableViewController {
    
    var bankSelectVC: BankSelectViewController?
    var preBank: String?
    var checkIndex = Int()
    
    var sectionRow = Int()
    let banks = [
        //あ行
        ["愛知銀行","あおぞら銀行","青森銀行","秋田銀行","足利銀行","アメリカ銀行","阿波銀行"],
        //い行
        ["イオン銀行","池田泉州銀行","伊予銀行","岩手銀行"],
        //う行
        ["上田信用金庫","魚津市農業協同組合","魚沼みなみ農業協同組合","羽後信用金庫","うご農業協同組合","碓氷安中農業協同組合","内浦町農業協同組合","宇都宮農業協同組合","馬路村農業協同組合","うま農業協同組合","浦幌町農業協同組合","ウリ信用組合","宇和島信用金庫"],
        //え行
        ["ＳＭＢＣ信託銀行","ＳＢＪ銀行","愛媛銀行"],
        //お行
        ["大分銀行","大垣共立銀行","沖縄銀行","沖縄海邦銀行","オリックス銀行"],
        //か行
        ["香川銀行","鹿児島銀行","神奈川銀行","関西アーバン銀行"],
        //き行
        ["北九州銀行","北日本銀行","紀陽銀行","京都銀行","きらぼし銀行","きらやか銀行","近畿大阪銀行"],
        //く行
        ["熊本銀行","群馬銀行"],
        //け
        ["京葉銀行"],
        //こ
        ["高知銀行"],
        //さ
        ["西京銀行","埼玉りそな銀行","佐賀銀行","佐賀共栄銀行","山陰合同銀行"],
        //し
        ["滋賀銀行","四国銀行","資産管理サービス信託銀行","静岡銀行","静岡中央銀行","七十七銀行","シティバンク、エヌ・エイ","島根銀行","清水銀行","荘内銀行","新生銀行","親和銀行","ＧＭＯあおぞらネット銀行","ジェーピーモルガン銀行","じぶん銀行","ジャパンネット銀行","十八銀行","十六銀行","常陽銀行"],
        //す
        ["住信ＳＢＩネット銀行","スルガ銀行"],
        //せ
        ["セブン銀行","仙台銀行"],
        //そ
        ["ソニー銀行"],
        //た
        ["大光銀行","大正銀行","但馬銀行","第三銀行","第四銀行","大東銀行","大和ネクスト銀行"],
        //ち
        ["筑邦銀行","千葉銀行","千葉興業銀行","中京銀行","中国銀行"],
        //つ
        ["筑波銀行"],
        //て
        ["天塩町農業協同組合","テラル越前農業協同組合","天童市農業協同組合","天白信用農業協同組合"],
        //と
        ["東京スター銀行","東邦銀行","東北銀行","東和銀行","徳島銀行","栃木銀行","鳥取銀行","トマト銀行","富山銀行","富山第一銀行","ドイツ銀行"],
        //な
        ["長崎銀行","長野銀行","名古屋銀行","南都銀行"],
        //に
        ["西日本シティ銀行","日本トラスティサービス信託銀行","日本マスタートラスト信託銀行"],
        //ぬ
        ["沼津信用金庫"],
        //ね
        ["根上農業協同組合"],
        //の
        ["野村信託銀行"],
        //は
        ["八十二銀行"],
        //ひ
        ["東日本銀行","肥後銀行","百五銀行","百十四銀行","広島銀行"],
        //ふ
        ["福井銀行","福岡銀行","福岡中央銀行","福島銀行","福邦銀行"],
        //へ
        ["碧海信用金庫","べっぷ日出農業協同組合"],
        //ほ
        ["豊和銀行","北越銀行","北都銀行","北洋銀行","北陸銀行","北海道銀行","北國銀行","香港上海銀行"],
        //ま
        ["毎日信用組合"],
        //み
        ["三重銀行","みずほ銀行","みずほ信託銀行","みちのく銀行","三井住友銀行","三井住友信託銀行","三菱ＵＦＪ信託銀行","三菱ＵＦＪ銀行","みなと銀行","南日本銀行","宮崎銀行","宮崎太陽銀行"],
        //む
        ["武蔵野銀行"],
        //め
        ["めぐみの農業協同組合","目黒信用金庫","女満別町農業協同組合","芽室町農業協同組合"],
        //も
        ["もみじ銀行"],
        //や
        ["山形銀行","山口銀行","山梨中央銀行"],
        //ゆ
        ["ゆうちょ銀行"],
        //よ
        ["横浜銀行"],
        //ら
        ["楽天銀行"],
        //り
        ["りそな銀行","琉球銀行"],
        //る
        ["留萌信用金庫"],
        //れ
        ["苓北町農業協同組合"],
        //ろ
        ["労働金庫連合会"],
        //わ
        ["若狭農業協同組合","和歌山県医師信用組合","和歌山県信用農業協同組合連合会","わかやま農業協同組合","稚内信用金庫","稚内農業協同組合"]
    ]
    
    var delegate: BankListTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        checkIndex = 0
        var checkFlg = false
        print(preBank)
        if let preBank = preBank {
            banks[sectionRow].forEach { (mainBank) in
                
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.chooseBank(bankName: banks[sectionRow][indexPath.row])
        _ = self.navigationController?.popToViewController(bankSelectVC!, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return banks[sectionRow].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0", for: indexPath)
        cell.textLabel?.text = banks[sectionRow][indexPath.row]

        if let _ = preBank {
            if checkIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }

}
