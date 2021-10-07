//
//  BrandTableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/04.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SHSearchBar


protocol BrandTableViewControllerDelegate {
    func brandType(brand: String)
}

class BrandTableViewController: UITableViewController, SHSearchBarDelegate {
    
    var preBrand: String?
    let headers = [" ","ア行","カ行","サ行","タ行","ナ行","ハ行","マ行","ラ行"]
    
    var searchBar: SHSearchBar!
    var rasterSize: CGFloat = 11.0
    let searchbarHeight: CGFloat = 44.0
    
    var addBrandTextField: UITextField?
    
    var delegate: BrandTableViewControllerDelegate?
    
    var selectedBrands = [BrandAll]()
    
    var searchFlg = false
    
    //Array<Array<BrandAll>> 何も検索してないときに表示する用(Headerを表示させるために、多次元配列になってる。)
    var brands = [
        
        //ブランドなし
        [BrandAll(enName: "メーカー名なし", jpName: "", jpHira: ""),
         BrandAll(enName: "その他", jpName: "", jpHira: "")],
        
        // ア行
        [BrandAll(enName: "OLYMPUS", jpName: "オリンパス", jpHira: "おりんぱす")
            ],
        //カ行
        [BrandAll(enName: "CASIO", jpName: "カシオ", jpHira: "かしお"),
         BrandAll(enName: "Carl Zeiss", jpName: "カールツァイス", jpHira: "かーるつぁいす"),
         BrandAll(enName: "Canon", jpName: "キャノン", jpHira: "きゃのん"),
         BrandAll(enName: "KenkoTokina", jpName: "ケンコー トキナー", jpHira: "けんこー ときなー"),
         BrandAll(enName: "COSINA", jpName: "コシナ", jpHira: "こしな"),
         BrandAll(enName: "KONICA MINOLTA", jpName: "コニカ ミノルタ", jpHira: "こにか みのるた"),
         BrandAll(enName: "CONTAX", jpName: "コンタックス", jpHira: "こんたっくす"),
         ],
        //サ行
        [BrandAll(enName: "SAMSUNG", jpName: "サムスン", jpHira: "さむすん"),
         BrandAll(enName: "SAMYANG", jpName: "サムヤン", jpHira: "さむやん"),
         BrandAll(enName: "SANYO", jpName: "サンヨー", jpHira: "さんよー"),
         BrandAll(enName: "SIGMA", jpName: "シグマ", jpHira: "しぐま"),
         BrandAll(enName: "SHARP", jpName: "シャープ", jpHira: "しゃーぷ"),
         BrandAll(enName: "Schneider", jpName: "シュナイダー", jpHira: "しゅないだー"),
         BrandAll(enName: "SONY", jpName: "ソニー", jpHira: "そにー"),
         ],
        //タ行
        [BrandAll(enName: "TAMRON", jpName: "タムロン", jpHira: "たむろん"),
         BrandAll(enName: "TOKINA", jpName: "トキナー", jpHira: "ときなー"),
         ],
        //ナ行
        [BrandAll(enName: "Nikon", jpName: "ニコン", jpHira: "にこん"),
         ],
        //ハ行
        [BrandAll(enName: "Hasselblad", jpName: "ハッセルブラッド", jpHira: "はっせるぶらっど"),
         BrandAll(enName: "Panasonic", jpName: "パナソニック", jpHira: "ぱなそにっく"),
         BrandAll(enName: "FUJIFILM", jpName: "富士フィルム", jpHira: "ふじふぃるむ"),
         BrandAll(enName: "Planar", jpName: "プラナー", jpHira: "ぷらなー"),
         BrandAll(enName: "PENTAX", jpName: "ペンタックス", jpHira: "ぺんたっくす"),

         ],
        //マ行
        [
         BrandAll(enName: "Mamiya", jpName: "マミヤ", jpHira: "まみや"),
         ],
        //ラ行
        [BrandAll(enName: "Leica", jpName: "ライカ", jpHira: "らいか"),
         BrandAll(enName: "RICOH", jpName: "リコー", jpHira: "りこー"),
         BrandAll(enName: "Rollei", jpName: "ローライ", jpHira: "ろーらい"),

         ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearch()
    }
    
    func setSearch() {
        let searchGlassIconTemplate = UIImage(named: "icon-search")!.withRenderingMode(.alwaysTemplate)
        
        // TODO: SearchBar4: centered text lets the icon on the left - this is not intended!
        let leftView = imageViewWithIcon(searchGlassIconTemplate, rasterSize: rasterSize)
        searchBar = defaultSearchBar(withRasterSize: rasterSize, leftView: leftView, rightView: nil, delegate: self)
        searchBar.textAlignment = .left
        //    searchBar.text = NSLocalizedString("sbe.exampleText.centered", comment: "")
        
        searchBar.textField.returnKeyType = .search
        
        navigationItem.titleView = searchBar
        
    }
    
    func imageViewWithIcon(_ icon: UIImage, rasterSize: CGFloat) -> UIImageView {
        let imgView = UIImageView(image: icon)
        imgView.frame = CGRect(x: 0, y: 0, width: icon.size.width + rasterSize * 2.0, height: icon.size.height)
        imgView.contentMode = .center
        imgView.tintColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        return imgView
    }
    
    func defaultSearchBar(withRasterSize rasterSize: CGFloat, leftView: UIView?, rightView: UIView?, delegate: SHSearchBarDelegate, useCancelButton: Bool = true) -> SHSearchBar {
        var config = defaultSearchBarConfig(rasterSize)
        config.leftView = leftView
        config.rightView = rightView
        config.useCancelButton = useCancelButton
        
        if leftView != nil {
            config.leftViewMode = .always
        }
        
        if rightView != nil {
            config.rightViewMode = .unlessEditing
        }
        
        let bar = SHSearchBar(config: config)
        bar.delegate = delegate
        bar.placeholder = NSLocalizedString("検索                                                        ", comment: "")
        bar.updateBackgroundImage(withRadius: 6, corners: [.allCorners], color: UIColor.white)
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOffset = CGSize(width: 0, height: 3)
        bar.layer.shadowRadius = 5
        bar.layer.shadowOpacity = 0.25
        return bar
    }
    
    func defaultSearchBarConfig(_ rasterSize: CGFloat) -> SHSearchBarConfig {
        var config: SHSearchBarConfig = SHSearchBarConfig()
        config.rasterSize = rasterSize
        config.cancelButtonTextAttributes = [.foregroundColor : UIColor.darkGray]
        config.textContentType = UITextContentType.fullStreetAddress.rawValue
        config.textAttributes = [.foregroundColor : UIColor.gray]
        return config
    }
    
    func searchBar(_ searchBar: SHSearchBar, textDidChange text: String) {
        
        print("text \(text)")
        
        
        if text == "" {
            searchFlg = false
            self.tableView.reloadData()
        } else {
            searchFlg = true
            selectedBrands.removeAll()
            self.tableView.reloadData()
            brands.forEach { (brandList) in
                brandList.forEach({ (brand) in
                    if (brand.enName.lowercased().contains(text.lowercased())) || (brand.jpName.contains(text)) || (brand.jpHira.contains(text)) {
                        self.selectedBrands.append(brand)
                    }
                })
            }

            self.tableView.reloadData()
        }
    }
    
    func searchBarShouldCancel(_ searchBar: SHSearchBar) -> Bool {
        print("cancelClick")
        
        searchFlg = false
        DispatchQueue.main.async {
            self.searchBar.text = ""
        }
        
        self.tableView.reloadData()
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !searchFlg {
            
            if brands[indexPath.section][indexPath.row].enName == "その他" {
                addTextFieldInUIAlertcontroller()
            } else {
                delegate?.brandType(brand: brands[indexPath.section][indexPath.row].enName)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            delegate?.brandType(brand: selectedBrands[indexPath.row].enName)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if !searchFlg {
            return headers[section]
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.gray
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if !searchFlg {
            return brands.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if !searchFlg {
            return brands[section].count
        } else {
            return selectedBrands.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if !searchFlg {
            let brand = brands[indexPath.section][indexPath.row]
            
            cell.textLabel?.text = brand.enName
            cell.detailTextLabel?.text = brand.jpName
            
            if let preBrand = preBrand {
                if preBrand == brands[indexPath.section][indexPath.row].enName {
                    cell.textLabel?.textColor = UIColor.red
                    cell.detailTextLabel?.textColor = UIColor.red
                    cell.accessoryType = .checkmark
                } else {
                    cell.textLabel?.textColor = UIColor.black
                    cell.detailTextLabel?.textColor = UIColor.black
                    cell.accessoryType = .none
                }
            }
            
            return cell
            
        } else {
            let brand = selectedBrands[indexPath.row]
            
            cell.textLabel?.text = brand.enName
            cell.detailTextLabel?.text = brand.jpName
            
            if let preBrand = preBrand {
                if preBrand == selectedBrands[indexPath.row].enName {
                    cell.textLabel?.textColor = UIColor.red
                    cell.detailTextLabel?.textColor = UIColor.red
                    cell.accessoryType = .checkmark
                } else {
                    cell.textLabel?.textColor = UIColor.black
                    cell.detailTextLabel?.textColor = UIColor.black
                    cell.accessoryType = .none
                }
            }
            
            return cell
        }
        
    }
    
    
    func addTextFieldInUIAlertcontroller() {
        let alertController = UIAlertController(title: "その他のメーカー", message: "お探しのメーカーが一覧にない場合はメーカー名を入力してください。", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: addBrandTextField)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            
            guard let addTex = self.addBrandTextField?.text else {return}
            if addTex == "" {
                ProgressHUD.showError("メーカー名を入力してください。")
                return;
            }
            self.delegate?.brandType(brand: addTex)
            if let currentUid = Api.User.CURRENT_USER?.uid {
                let autoId = Api.Brand.REF_BRAND_CANDIDATES.childByAutoId().key
                Api.Brand.REF_BRAND_CANDIDATES.child(currentUid).child(autoId!).setValue(["brand": addTex])
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel) { (alert) in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addBrandTextField(textField: UITextField!) {
        addBrandTextField = textField
        addBrandTextField?.placeholder = "メーカー名"
    }
    
}
