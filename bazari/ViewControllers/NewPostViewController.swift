//
//  NewPostViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/16.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import Photos
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var category: String?
    var brandStr: String?
    var status: String?
    
    //タプルを使って画像と順番を格納
    var tupleImages: [(image: UIImage, sort: Int)] = [(image: UIImage, sort: Int)]()
    var ratios = [Dictionary<String, CGFloat>]()
    var indexRow = Int()
    var shipPerson: String?
    var shipWay: String?
    var shipDate: String?
    var shipFromPrefecture: String?
    
    var add = "add"
    var nonadd = "nonadd"
    
    var titleText: String?
    var inputPrice: Int?
    
    var explainText: String?
    
    let userDefaults = UserDefaults.standard
    
    let shipPayments = ["送料込み (あなたが負担)","着払い (購入者が負担)"]
    let shipDates = Config.shipDatesList
    
    
    let SHIPPERSON = "shipPerson"
    let SHIPWAY = "shipWay"
    let SHIPDATE = "shipDate"
    let SHIPPREFECTURE = "shipPrefecture"
    
//    func putSet() {
//        category = "デジタルカメラ"
//        titleText = "タイトル1"
//        explainText = "キャプション1"
//        brandStr = "ブランド1"
//        status = "並品"
//        inputPrice = 5200
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let shipP = userDefaults.string(forKey: SHIPPERSON)
        
        if shipP == nil {
            shipPerson = shipPayments[0]
        } else {
            shipPerson = shipP
        }
        
        let shipW = userDefaults.string(forKey: SHIPWAY)
        let shipD = userDefaults.string(forKey: SHIPDATE)
        let shipPrefe = userDefaults.string(forKey: SHIPPREFECTURE)
        
        if shipW != nil {
            shipWay = shipW
        }
        
        if shipD == nil {
            shipDate = shipDates[2]
        } else {
            shipDate = shipD
        }
        
        if shipPrefe != nil {
            shipFromPrefecture = shipPrefe
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        tableView.reloadData()
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        AuthService.logout(onSuccess: {
            print("logout")
        }) { (error) in
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategory_Seg" {
            
            let categoryVC = segue.destination as! CategoryTableViewController
            let newPostSelf = sender as? NewPostViewController
            categoryVC.newPostVC = newPostSelf
            categoryVC.selectedCategoryStr = self.category
            categoryVC.delegate = self
        }
        
        if segue.identifier == "goToBrand_Seg" {
            
            let brandVC = segue.destination as! BrandTableViewController
            let brand = sender as? String
            brandVC.delegate = self
            brandVC.preBrand = brand
        }
        
        if segue.identifier == "goToProductStatus_Seg" {
            
            let productStatusVC = segue.destination as! ProductStatusTableViewController
            let productStatus = sender as? String
            productStatusVC.delegate = self
            productStatusVC.preProductStatus = productStatus
        }
        
        if segue.identifier == "ShipPayment_Seg" {
            
            let shipInfoWithSubtitleVC = segue.destination as! ShipInfoWithSubTitleTableViewController
            let shipPerson = sender as? String
            shipInfoWithSubtitleVC.delegate = self
            shipInfoWithSubtitleVC.preShipPayment = shipPerson
        }
        
        if segue.identifier == "ShipChoose_Seg" {
            
            let shipInfoVC = segue.destination as! ShipInfoTableViewController
            let num = sender as! Int
            shipInfoVC.delegate = self
            shipInfoVC.preShipTypeNum = num
            shipInfoVC.preShipPayment = shipPerson
            
            switch num {
            case 1:
                shipInfoVC.chosenShipType = shipWay
            case 2:
                shipInfoVC.chosenShipType = shipDate
            case 3:
                shipInfoVC.chosenShipType = shipFromPrefecture
            default:
                print("t")
            }
        }
        
        
        if segue.identifier == "goToExplain_Seg" {
            
            let explainVC = segue.destination as! ExplainProductViewController
            explainVC.delegate = self
            explainVC.tex = explainText
            
        }
    }
    
    
}

extension NewPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 105
        case 1:
            return 44
        case 2:
            return 44
        case 3:
            if explainText == nil {
                return 134
            } else {
                return UITableViewAutomaticDimension
            }
        case 4:
            return 44
        case 5:
            return UITableViewAutomaticDimension
            
        case 9:
            return 138
        case 10:
            return 177
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultiPostTableViewCell", for: indexPath) as! MultiPostTableViewCell
            
            cell.collectionView.dataSource = self
            cell.collectionView.reloadData()
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDefultCellTableViewCell0", for: indexPath) as! PostDefultCellTableViewCell
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleInputTableViewCell", for: indexPath) as! TitleInputTableViewCell
            cell.delegate = self
            
            if self.titleText == nil {
                cell.titleTextField.text = ""
            }
            
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductExplainInputTableViewCell", for: indexPath) as! ProductExplainInputTableViewCell
            
            if self.explainText == nil {
                cell.explainTextView.text = ""
            } else {
                cell.explainTextView.text = self.explainText!
            }
            
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDefultCellTableViewCell1", for: indexPath) as! PostDefultCellTableViewCell
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductInformationTableViewCell", for: indexPath) as! ProductInformationTableViewCell
            
            if indexPath.row == 0 {
                cell.lbl1.text = "カテゴリー"
                
                if let _ = category {
                    cell.infoLbl.textColor = UIColor.black
                    cell.infoLbl.text = category
                } else {
                    cell.infoLbl.textColor =  UIColor.lightGray
                    cell.infoLbl.text = "(必須)"
                }
                
            } else if indexPath.row == 1 {
                cell.lbl1.text = "メーカー"
                if let brand = brandStr {
                    cell.infoLbl.textColor = UIColor.black
                    cell.infoLbl.text = brand
                } else {
                    cell.infoLbl.textColor =  UIColor.lightGray
                    cell.infoLbl.text = "(任意)"
                }
            } else {
                cell.lbl1.text = "商品の状態"
                
                if let status = status {
                    cell.infoLbl.textColor = UIColor.black
                    cell.infoLbl.text = status
                } else {
                    cell.infoLbl.textColor =  UIColor.lightGray
                    cell.infoLbl.text = "(必須)"
                }
            }
            
            return cell
            
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDefultCellTableViewCell2", for: indexPath) as! PostDefultCellTableViewCell
            
            return cell
            
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShipInfoTableViewCell", for: indexPath) as! ShipInfoTableViewCell
            
            if indexPath.row == 0 {
                cell.lbl1.text = "配送料の負担"
                if let shipPerson = shipPerson {
                    cell.shipInfoLbl.textColor = UIColor.black
                    cell.shipInfoLbl.text = shipPerson
                } else {
                    cell.shipInfoLbl.textColor =  UIColor.lightGray
                    cell.shipInfoLbl.text = "(必須)"
                }
            } else if indexPath.row == 1 {
                cell.lbl1.text = "配送方法"
                if let shipWay = shipWay {
                    cell.shipInfoLbl.textColor = UIColor.black
                    cell.shipInfoLbl.text = shipWay
                } else {
                    cell.shipInfoLbl.textColor =  UIColor.lightGray
                    cell.shipInfoLbl.text = "(任意)"
                }
            } else if indexPath.row == 2 {
                cell.lbl1.text = "配送日の目安"
                if let shipDate = shipDate {
                    cell.shipInfoLbl.textColor = UIColor.black
                    cell.shipInfoLbl.text = shipDate
                } else {
                    cell.shipInfoLbl.textColor =  UIColor.lightGray
                    cell.shipInfoLbl.text = "(必須)"
                }
            } else if indexPath.row == 3 {
                cell.lbl1.text = "配送元の地域"
                if let shipFromPrefecture = shipFromPrefecture {
                    cell.shipInfoLbl.textColor = UIColor.black
                    cell.shipInfoLbl.text = shipFromPrefecture
                } else {
                    cell.shipInfoLbl.textColor = UIColor.lightGray
                    cell.shipInfoLbl.text = "(必須)"
                }
            }
            
            return cell
            
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostDefultCellTableViewCell3", for: indexPath) as! PostDefultCellTableViewCell
            
            return cell
            
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceInputTableViewCell", for: indexPath) as! PriceInputTableViewCell
            cell.delegate = self
            if self.inputPrice == nil {
                cell.priceInputTextField.text = ""
                cell.commisionLbl.text = ""
                cell.profitLbl.text = ""
            }
            
            return cell
            
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckTableViewCell", for: indexPath) as! CheckTableViewCell
            cell.delegate = self
            cell.postBtn.isEnabled = true
            cell.draftBtn.isEnabled = true
            return cell
            
        default:
            print("t")
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 5:
            return 3
        case 7:
            return 4
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let _ = Api.User.CURRENT_USER?.uid else {return}
        
        switch indexPath.section {
        case 3:
            performSegue(withIdentifier: "goToExplain_Seg", sender: nil)
        case 5:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "goToCategory_Seg", sender: self)
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "goToBrand_Seg", sender: brandStr)
            } else {
                performSegue(withIdentifier: "goToProductStatus_Seg", sender: status)
            }
        case 7:
            
            if indexPath.row == 0 {
                performSegue(withIdentifier: "ShipPayment_Seg", sender: shipPerson)
            } else {
                print(indexPath.row)
                performSegue(withIdentifier: "ShipChoose_Seg", sender: indexPath.row)
            }
        default:
            print("t")
        }
    }
}

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            let ratioWidth = image.size.height / image.size.width
            let ratioHeight = image.size.width / image.size.height
            
            var ratioDict: Dictionary<String, CGFloat> = [:]
            ratioDict[Config.ratioWidthKey] = ratioWidth
            ratioDict[Config.ratioHeightKey] = ratioHeight

            if tupleImages.canAccess(index: indexRow) {
                tupleImages[indexRow] = (image, indexRow)
                ratios[indexRow] = ratioDict
                
            } else {
                tupleImages.append((image: image, sort: tupleImages.count))
                ratios.append(ratioDict)
            }
            
            if picker.sourceType == .camera {
                //アルバムに追加
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //カメラがキャンセルされたときに呼ばれるメソッド
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension NewPostViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostPhotoCollectionViewCell", for: indexPath) as! PostPhotoCollectionViewCell
        if tupleImages.count != 0 {
            var select = UIImage()
            
            if (tupleImages.count) > indexPath.item {
                cell.closeButton.isHidden = false
                select = tupleImages[indexPath.row].image
                
            } else if tupleImages.count == indexPath.item {
                cell.rightSideConstraint.constant = 0
                cell.leftSideConstraint.constant = 0
                cell.closeButton.isHidden = true
                select = UIImage(named: add + ".JPG")!
            } else {
                cell.rightSideConstraint.constant = 0
                cell.leftSideConstraint.constant = 0
                cell.closeButton.isHidden = true
                select = UIImage(named: nonadd + ".JPG")!
            }
            cell.photo.image = select
            cell.photoImage = select
            cell.delegate = self
            cell.indexRow = indexPath.row
                    
            return cell
        }
        else {
            
            switch indexPath.item {
            case 0:
                cell.photo.image = UIImage(named: add + ".JPG")
            case 1:
                cell.photo.image = UIImage(named: nonadd + ".JPG")
            case 2:
                cell.photo.image = UIImage(named: nonadd + ".JPG")
            case 3:
                cell.photo.image = UIImage(named: nonadd + ".JPG")
                
            default:
                print("t")
            }
            cell.delegate = self
            cell.closeButton.isHidden = true
            cell.indexRow = indexPath.row
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4;
        
    }
}


extension NewPostViewController: CategoryTableViewControllerDelegate, ProductStatusTableViewControllerDelegate, BrandTableViewControllerDelegate, ShipInfoWithSubTitleTableViewControllerDelegate, ShipInfoTableViewControllerDelegate, ExplainProductViewControllerDelegate, CheckTableViewCellDelegate, TitleInputTableViewCellDelegate, PriceInputTableViewCellDelegate {
    
    func draftPost() {
        
        guard let _ = Api.User.CURRENT_USER?.uid else {
            print("noAuth")
            //postBtn.isEnabled = true ,draftBtn.isEnabled = true にするため、self.tableView.reloadData()する。
            self.tableView.reloadData()
            self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            
            return
            
        }
        
        if tupleImages.count == 0 {
            //postBtn.isEnabled = true ,draftBtn.isEnabled = true にするため、self.tableView.reloadData()する。
            self.tableView.reloadData()
            ProgressHUD.showError("商品画像は１枚以上選択してください。")
            return;
        } else if titleText == nil {
            //postBtn.isEnabled = true ,draftBtn.isEnabled = true にするため、self.tableView.reloadData()する。
            self.tableView.reloadData()
            ProgressHUD.showError("商品名を入力してください。")
            return;
        }
        
        if let _ = inputPrice {
            if inputPrice! > Config.maximumPrice {
                ProgressHUD.showError("商品価格の上限は\(Functions.formatPrice(price: Config.maximumPrice))円です。")
                self.tableView.reloadData()
                return;
            }
        }
        
        
        self.showAlert(title: "保存しますか？", message: "", isNewPostFlg: false)
    }
    
    func uploadDraft() {
        
        SVProgressHUD.show()
        HelperService.draftPostDataToServer(tupleImages: tupleImages, ratios: ratios, imageCount: tupleImages.count, title: titleText, caption: explainText, category1: Config.CAMERA, category2: category, status: status, shipPayer: shipPerson, shipWay: shipWay, shipDate: shipDate, shipFrom: shipFromPrefecture, price: inputPrice, brand: brandStr, onSuccess: {

            SVProgressHUD.dismiss()
            self.clean()
            self.tableView.reloadData()
            ProgressHUD.showSuccess("保存しました。")
            self.tabBarController?.selectedIndex = 0

            print("保存しました。")
        }, onError: {
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        })
    }
    
    
    
    func changePrice(inputPrice: Int?) {
        self.inputPrice = inputPrice
    }
    
    func changeTitle(text: String) {
        
        if text == "" {
            titleText = nil
        } else {
            titleText = text
        }
        
    }
    
    func explainProduct(explainText: String) {
        
        if explainText == "" {
            self.explainText = nil
        } else {
            self.explainText = explainText
        }
        
    }
    
    
    
    
    func shipType(shipType: String, shipTypeNum: Int) {
        switch shipTypeNum {
        case 1:
            shipWay = shipType
        case 2:
            shipDate = shipType
        case 3:
            shipFromPrefecture = shipType
            
            
        default:
            print("t")
        }
    }
    
    
    func shipPaymentType(shipPayment: String, hasChanged: Bool) {
        self.shipPerson = shipPayment
        
        if hasChanged {
            self.shipWay = nil
        }
    }
    
    func brandType(brand: String) {
        self.brandStr = brand
    }
    
    func productStatusType(productStatus: String) {
        self.status = productStatus
    }
    
    func categoryType(category: String) {
        
        self.category = category
    }
    
    func newPost() {
        
        guard let _ = Api.User.CURRENT_USER?.uid else {
            print("noAuth")
            self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            
            return}
    
        if tupleImages.count == 0 {
            ProgressHUD.showError("商品画像は１枚以上選択してください。")
            self.tableView.reloadData()
            return;
        } else if titleText == nil {
            ProgressHUD.showError("商品名を入力してください。")
            self.tableView.reloadData()
            return;
        } else if explainText == nil {
            ProgressHUD.showError("商品の説明を入力してください。")
            self.tableView.reloadData()
            return;
        } else if category == nil {
            ProgressHUD.showError("カテゴリを選択してください。")
            self.tableView.reloadData()
            return;
        } else if status == nil {
            ProgressHUD.showError("商品の状態を選択してください。")
            self.tableView.reloadData()
            return;
        } else if shipFromPrefecture == nil {
            ProgressHUD.showError("発送元の地域を選択してください。")
            self.tableView.reloadData()
            return;
        } else if inputPrice == nil {
            ProgressHUD.showError("商品価格を入力してください。")
            self.tableView.reloadData()
            return;
        } else  {
            if inputPrice! < Config.minimumPrice {
                ProgressHUD.showError("商品価格は、\(Config.minimumPrice)円以上で設定してください。")
                self.tableView.reloadData()
                return;
            } else if inputPrice! > Config.maximumPrice {
                ProgressHUD.showError("商品価格の上限は\(Functions.formatPrice(price: Config.maximumPrice))円です。")
                self.tableView.reloadData()
                return;
            }
        }
        
        if brandStr == "メーカー名なし" {
            brandStr = nil
        }
        
        if shipWay == nil {
            shipWay = "未定"
        }
        
        userDefaults.set(shipPerson!, forKey: SHIPPERSON)
        if shipWay != "未定" {
            userDefaults.set(shipWay!, forKey: SHIPWAY)
        } else {
            userDefaults.removeObject(forKey: SHIPWAY)
        }
        userDefaults.set(shipDate!, forKey: SHIPDATE)
        userDefaults.set(shipFromPrefecture!, forKey: SHIPPREFECTURE)
        
        showAlert(title: "投稿していいですか？", message: "", isNewPostFlg: true)
        
        
    }
    
    
    func uploadPost() {
        
        SVProgressHUD.show()
        HelperService.uploadDataToServer(tupleImages: tupleImages, ratios: ratios, imageCount: tupleImages.count, title: titleText!, caption: explainText!, category1: Config.CAMERA, category2: category!, status: status!, shipPayer: shipPerson!, shipWay: shipWay!, shipDate: shipDate!, shipFrom: shipFromPrefecture!, price: inputPrice!, brand: brandStr, onSuccess: {
            
            SVProgressHUD.dismiss()
            self.clean()
            self.tableView.reloadData()
            ProgressHUD.showSuccess("投稿しました。")
            self.tabBarController?.selectedIndex = 0
            print("Postしました。")
            
        }, onError: {
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        })
        

    }
    
    
    func clean() {
        category = nil
        brandStr = nil
        status = nil
        tupleImages.removeAll()
        ratios.removeAll()
        indexRow = Int()
        titleText = nil
        inputPrice = nil
        explainText = nil
        
    }
    
    
    func showAlert(title: String, message: String, isNewPostFlg: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let postOKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.uploadPost()
        })
        
        let draftOKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.uploadDraft()
        })
        
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            //postBtn.isEnabled = true ,draftBtn.isEnabled = true にするため、self.tableView.reloadData()する。
            self.tableView.reloadData()
        })
        
        if isNewPostFlg {
            alert.addAction(postOKAction)
            alert.addAction(cancelAction)
        } else {
            alert.addAction(draftOKAction)
            alert.addAction(cancelAction)
            
        }
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActionPhoto(indexRow: Int) {
        // create menu controller
        let menu = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        let albumAction = UIAlertAction(title: "アルバムから選択", style: .default) { (UIAlertAction) -> Void in
            
            
            //写真へのアクセスの許可アラート
            PHPhotoLibrary.requestAuthorization { (status) in
                
                switch status {
                case .authorized:
                    print("authorized")
                    //アルバムから画像を選択
                    let pickerController = UIImagePickerController()
                    pickerController.delegate = self
                    pickerController.mediaTypes = ["public.image", "public.movie"]
                    self.indexRow = indexRow
                    self.present(pickerController, animated: true, completion: nil)
                case .denied:
                    print("denied")
     //               ProgressHUD.showError("写真へのアクセスが拒否されております。")
                    self.showPermissionDeniedAlert(title: "写真へのアクセスが許可されていません。\n端末の「設定」 > 「プライバシー」 > 「写真」でバザリからの利用を許可して下さい。", message: "")
                    
                case .notDetermined:
                    print("notDetermind")
                case .restricted:
                    print("restricted")
                }
            }
            
            
        }
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (UIAlertAction) -> Void in
            
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if status == AVAuthorizationStatus.authorized {
                // アクセス許可あり
                //カメラを起動
                let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = sourceType
                self.indexRow = indexRow
                self.present(pickerController, animated: true, completion: nil)
                
            } else if status == AVAuthorizationStatus.restricted {
                // ユーザー自身にカメラへのアクセスが許可されていない
            } else if status == AVAuthorizationStatus.notDetermined {
                // まだアクセス許可を聞いていない
                
                //カメラを起動
                let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = sourceType
                self.indexRow = indexRow
                self.present(pickerController, animated: true, completion: nil)
                
            } else if status == AVAuthorizationStatus.denied {
                // アクセス許可されていない
        //        ProgressHUD.showError("カメラへのアクセスが拒否されております。")
                self.showPermissionDeniedAlert(title: "カメラへのアクセスが許可されていません。\n端末の「設定」 > 「プライバシー」 > 「カメラ」でバザリからの利用を許可して下さい。", message: "")
            }
            
           
        }
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        menu.addAction(albumAction)
        menu.addAction(cameraAction)
        menu.addAction(cancel)
        
        // iPadでは必須！
        menu.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        menu.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    func showPermissionDeniedAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default, handler: {(alert: UIAlertAction!) in
        })
        
        alert.addAction(closeAction)
        
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


extension NewPostViewController: PostPhotoCollectionViewCellDelegate {
    
    
    
    func removePick(indexRow: Int) {
        tupleImages.remove(at: indexRow)
        
        //削除した画像より後ろのタプルのソートを一つ繰り下げる
        var count = 0
        tupleImages.forEach { (tupleImage) in
            if indexRow < tupleImage.sort {
                self.tupleImages[count].sort = (self.tupleImages[count].sort - 1)
            }
            count += 1
        }
        ratios.remove(at: indexRow)
        tableView.reloadData()
        
    }
    
    
    func photoPick(indexRow: Int) {
        
        if let _ = Api.User.CURRENT_USER?.uid {
            
            if indexRow > tupleImages.count  {
                return;
            }
            
            showActionPhoto(indexRow: indexRow)
            
        } else {
            print("noAuth")
            self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            
        }
    }
    
}

extension Array {
    func canAccess(index: Int) -> Bool {
        return self.count-1 >= index
    }
}
