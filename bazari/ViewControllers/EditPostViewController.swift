//
//  EditPostViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol EditPostViewControllerDelegate {
    func updatePost()
}

class EditPostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: EditPostViewControllerDelegate?
    
    var category: String?
    var brandStr: String?
    var status: String?
    
    var tupleImages: [(image: UIImage, sort: Int)] = [(image: UIImage, sort: Int)]()
    var ratios = [Dictionary<String, CGFloat>]()
    var indexRow = Int()
    var shipPerson: String?
    var shipWay: String?
    var shipDate: String?
    var shipFromPrefecture: String?
    
    var post = Post()
    
    var add = "add"
    var nonadd = "nonadd"
    
    var preTitleText: String?
    var titleText: String?
    var preInputPrice: Int?
    var inputPrice: Int?
    var defaultInputPrice: Int?
    
    var explainText: String?
    var currentUid = String()
    
    let shipPayments = ["送料込み (あなたが負担)","着払い (購入者が負担)"]
    let shipDates = Config.shipDatesList
    
    
    let SHIPPERSON = "shipPerson"
    let SHIPWAY = "shipWay"
    let SHIPDATE = "shipDate"
    let SHIPPREFECTURE = "shipPrefecture"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        category = post.category2
        brandStr = post.brand
        status = post.status
        ratios = post.ratios
        shipPerson = post.shipPayer
        shipWay = post.shipWay
        shipDate = post.shipDeadLine
        shipFromPrefecture = post.shipFrom
        preTitleText = post.title
        titleText = post.title
        preInputPrice = post.price
        inputPrice = post.price
        defaultInputPrice = post.price
        explainText = post.caption
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCategory_Seg" {
            
            let categoryVC = segue.destination as! CategoryTableViewController
            categoryVC.delegate = self
            categoryVC.selectedCategoryStr = self.category
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
    
    func showActionPhoto(indexRow: Int) {
        // create menu controller
        let menu = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        let album = UIAlertAction(title: "アルバムから選択", style: .default) { (UIAlertAction) -> Void in
            //アルバムから画像を選択
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.mediaTypes = ["public.image", "public.movie"]
            self.indexRow = indexRow
            self.present(pickerController, animated: true, completion: nil)
        }
        let camera = UIAlertAction(title: "カメラで撮影", style: .default) { (UIAlertAction) -> Void in
            //カメラを起動
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = sourceType
            self.indexRow = indexRow
            self.present(pickerController, animated: true, completion: nil)
        }
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        menu.addAction(album)
        menu.addAction(camera)
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
}

extension EditPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 95
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
            return 75
        case 11:
            return 75
            
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
            
            if let _ = preTitleText {
                cell.titleTextField.text = preTitleText
                preTitleText = nil
            }
            cell.delegate = self
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
                
                if let category = category {
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
            
            if let _ = preInputPrice {
                cell.priceInputTextField.text = "\(preInputPrice!)"
                cell.textFieldDidChange()
                preInputPrice = nil
            }
            cell.delegate = self
            return cell
            
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckTableViewCell", for: indexPath) as! CheckTableViewCell
            cell.postBtn.isEnabled = true
            if let _ = cell.draftBtn {
                cell.draftBtn.isEnabled = true
            }
            cell.delegate = self
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

extension EditPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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


extension EditPostViewController: UICollectionViewDataSource {
    
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


extension EditPostViewController: CategoryTableViewControllerDelegate, ProductStatusTableViewControllerDelegate, BrandTableViewControllerDelegate, ShipInfoWithSubTitleTableViewControllerDelegate, ShipInfoTableViewControllerDelegate, ExplainProductViewControllerDelegate, CheckTableViewCellDelegate, TitleInputTableViewCellDelegate, PriceInputTableViewCellDelegate {
    
    func draftPost() {
        print("nothinghere")
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
        } else {
            if inputPrice! < Config.minimumPrice {
                ProgressHUD.showError("商品価格は、\(Config.minimumPrice)円以上で設定してください。")
                self.tableView.reloadData()
                return;
            }  else if inputPrice! > Config.maximumPrice {
                ProgressHUD.showError("商品価格の上限は\(Functions.formatPrice(price: Config.maximumPrice))円です。")
                self.tableView.reloadData()
                return;
            }
        }
        
        if shipWay == nil {
            shipWay = "未定"
        }
        
        showAlert(title: "投稿していいですか？", message: "")
        
        
    }
    
    func priceDown() {
        //値下げした
        if let defaultInputPrice = defaultInputPrice {
            if defaultInputPrice > inputPrice! {
                
                let timestamp = Int(Date().timeIntervalSince1970)
                
                if let _ = self.post.likes {
                    for like in self.post.likes! {
                        let userId = like.key
                        
                        if userId != self.currentUid {
                            Api.Notification.observeExistNotification(uid: userId, postId: self.post.id!, type: "priceDown", currentUid: self.currentUid) { (notificationId) in
                                
                                if notificationId == nil {
                                    let autoKey = Api.Notification.REF_MYNOTIFICATION.child(userId).childByAutoId().key
                                    Api.Notification.REF_MYNOTIFICATION.child(userId).child(autoKey!).setValue(["timestamp": timestamp])
                                    Api.Notification.REF_NOTIFICATION.child(autoKey!).setValue(["checked": false, "from": Api.User.CURRENT_USER!.uid, "objectId": self.post.id!, "type": "priceDown", "timestamp": timestamp, "to": userId, "segmentType": Config.you])
                                    Api.Notification.REF_EXIST_NOTIFICATION.child(userId).child(self.currentUid).child(self.post.id!).child("priceDown").setValue([autoKey!: true])
                                    
                                } else {
                                    Api.Notification.REF_MYNOTIFICATION.child(userId).child(notificationId!).updateChildValues(["timestamp": timestamp])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadPost() {
        SVProgressHUD.show()
        if brandStr == "メーカー名なし" {
            brandStr = nil
        }
        HelperService.updateDataToServer(tupleImages: tupleImages, ratios: ratios, imageCount: tupleImages.count, title: titleText!, caption: explainText!, category1: Config.CAMERA, category2: category!, status: status!, shipPayer: shipPerson!, shipWay: shipWay!, shipDate: shipDate!, shipFrom: shipFromPrefecture!, price: inputPrice!, brand: brandStr, postId: post.id!, onSuccess: {
            SVProgressHUD.dismiss()
            self.delegate?.updatePost()
            self.tableView.reloadData()
            self.priceDown()
            _ = self.navigationController?.popViewController(animated: true)
        }, onError: {
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        })
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        
        
        let postOKAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            self.uploadPost()
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            //postBtn.isEnabled = true ,draftBtn.isEnabled = true にするため、self.tableView.reloadData()する。
            self.tableView.reloadData()
        })
        
        alert.addAction(postOKAction)
        alert.addAction(cancelAction)
        
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


extension EditPostViewController: PostPhotoCollectionViewCellDelegate {
    
    
    
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
        
        if indexRow > tupleImages.count  {
            return;
        }
        
        showActionPhoto(indexRow: indexRow)
        
    }
    
}
