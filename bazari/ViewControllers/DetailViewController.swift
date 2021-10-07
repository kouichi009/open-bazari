

import UIKit
import FRHyperLabel
import SVProgressHUD
import RegeributedTextView
import Toaster
import Repro.RPREventProperties

class DetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var ship_PayerLbl: UILabel!
    
    @IBOutlet weak var priceLbl: UILabel!
    
    var post: Post = Post()
    var usermodel: UserModel = UserModel()
    var comments: [Comment] = [Comment]()
    var usermodels: [UserModel] = [UserModel]()
    var currentPage = 0
    
    var postId = String()
    
    var commentTextViewHeight: CGFloat?
    
    var currentUid = String()
    
    var KOUNYUU = "購入手続きへ"
    var TORIHIKI = "取引ページへ"
    var SOLDOUT = "SOLD OUT"
    
    var isBlocked: Bool?
    
    var tableViewHeight: CGFloat? {
        didSet {
            updateTableViewHeight()
        }
    }
    
    func updateTableViewHeight() {
        self.tableViewHeightConstraint.constant = tableViewHeight!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        ship_PayerLbl.text = ""
        purchaseButton.setTitle("", for: UIControlState.normal)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        fetchAllUsers {
            self.observePost()
            
        }
        
    }
    
    func fetchBlockedUser(currentUid: String, userId: String) {
        Api.Block.isBlocked(currentUid: currentUid, userId: userId) { (isBlocked) in
            
            self.isBlocked = isBlocked
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        var idx = Int()
        
        
        
        idx = Int(x / view.frame.width)
        currentPage = idx
        if let _ = scrollView as? UICollectionView {
            tableView.reloadData()
        }
    }
    
    
    func observePost() {
        Api.Post.observePost(postId: postId) { (post) in
            
            //データなし
            if post == nil {
                ToastView.appearance().cornerRadius = 10
                ToastView.appearance().backgroundColor = .gray
                ToastView.appearance().bottomOffsetPortrait = 100
                ToastView.appearance().font = .systemFont(ofSize: 16)
                Toast(text: "データがありませんでした。").show()
                _ = self.navigationController?.popViewController(animated: true)
                return;
                
            }
            
            if let post = post {
                self.post = post
                
                if let currentUid = Api.User.CURRENT_USER?.uid {
                    self.currentUid = currentUid
                    self.fetchBlockedUser(currentUid: currentUid, userId: post.uid!)
                }
                
                self.title = post.title!
                if Config.shipPayerList[0] == post.shipPayer {
                    self.ship_PayerLbl.text = "送料込み"
                } else {
                    self.ship_PayerLbl.text = ""
                }
                
                let newPrice = Functions.formatPrice(price: post.price!)
                self.priceLbl.text = "¥\(newPrice)"
                
                if post.transactionStatus == Config.sell && post.uid != self.currentUid {
                    self.purchaseButton.setTitle(self.KOUNYUU, for: UIControlState.normal)
                    self.reproAnalyticsDetailPage()
                    
                } else if post.transactionStatus == Config.sell && post.uid == self.currentUid {
                    self.purchaseButton.isHidden = true
                    
                } else {
                    self.purchaseButton.isEnabled = false
                    self.purchaseButton.backgroundColor = UIColor.lightGray
                    self.purchaseButton.setTitle(self.SOLDOUT, for: UIControlState.normal)
                }
                
                Api.User.observeUser(withId: post.uid!, completion: { (usermodel) in
                    
                    if let usermodel = usermodel {
                        self.usermodel = usermodel
                    }
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
                })
                
                
            }
        }
        var count = 0
        self.comments.removeAll()
        Api.Comment.observePostComments(postId: postId) { (comment, commentCount) in
            
            count += 1
            
            if let comment = comment {
                self.comments.insert(comment, at: 0)
            }
            if count == commentCount {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func reproAnalyticsDetailPage() {
        let properties = RPRViewContentProperties()
        
        if let price = post.price {
            properties.value = Double(price)
            properties.currency = "JPY"
            properties.contentName = post.title
            
            var category: String?
            if let category2 = post.category2 {
                category = category2
            }
            
            if let category = category {
                properties.contentCategory = category
            }
            Repro.trackViewContent(post.id, properties: properties)
        }
        
        
    }
    
    func fetchAllUsers(completion: @escaping () -> Void) {
        self.usermodels.removeAll()
        var count = 0
        Api.User.observeAllUsers { (usermodel, userCount) in
            
            count += 1
            
            if let usermodel = usermodel {
                self.usermodels.append(usermodel)
            }
            
            if count == userCount {
                completion()
            }
        }
    }
    
    @IBAction func goToPurchase_TouchUpInside(_ sender: Any) {
        
        if purchaseButton.currentTitle == KOUNYUU {
            
            if let _ = Api.User.CURRENT_USER?.uid {
                
                guard let isBlocked = isBlocked else {return}
                if isBlocked {
                    ProgressHUD.showError("ブロックされています。")
                    return;
                }
                purchaseButton.isEnabled = false
                SVProgressHUD.show()
                Api.Address.observeAddress(userId: currentUid) { (address) in
                    
                    self.purchaseButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    if let address = address {
                        
                        
                        //住所が登録済みであれば
                        if let _ = address.seiKanji {
                            self.reproAnalyticsInitiateCheckout()
                            self.performSegue(withIdentifier: "goToPurchase_Seg", sender: self.post.id)
                        }
                            //住所が未登録であれば、
                        else {
                            self.performSegue(withIdentifier: "goToAddress_Seg", sender: nil)
                        }
                        
                    }
                        //住所も電話番号も未登録であれば、
                    else {
                        self.performSegue(withIdentifier: "goToAddress_Seg", sender: nil)
                    }
                }
                
            } else {
                self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            }
        }
        
        
    }
    
    //支払い開始
    //ユーザーが「購入手続きへ」ボタンをタップしたとき
    func reproAnalyticsInitiateCheckout() {
        
        let properties = RPRInitiateCheckoutProperties()
        if let price = post.price {
            
            properties.value = Double(price)
            properties.currency = "JPY"
            properties.contentName = post.title
            var category: String?
            if let category2 = post.category2 {
                category = category2
            }
            
            if let category = category {
                properties.contentCategory = category
            }
            properties.contentID = post.id
            properties.numItems = 1
            
            Repro.trackInitiateCheckout(properties)
            
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPurchase_Seg" {
            let purchaseVC = segue.destination as! PurchaseViewController
            let postId = sender as? String
            purchaseVC.delegate = self
            purchaseVC.postId = postId!
            
        }
        
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let post = sender as? Post
            commentVC.delegate = self
            commentVC.post = post!
            commentVC.usermodel = usermodel
        }
        
        if segue.identifier == "EditPost_Seg" {
            let editVC = segue.destination as! EditPostViewController
            let images = sender as? [UIImage]
            var count = 0
            var tupleArray: [(image: UIImage, sort: Int)] = []
            images?.forEach({ (image) in
                tupleArray.append((image: image, sort: count))
                count += 1
            })
            editVC.delegate = self
            editVC.tupleImages = tupleArray
            editVC.post = self.post
            
        }
        
        if segue.identifier == "category_brand_Seg" {
            let category_brandVC = segue.destination as! Category_BrandViewController
            let category_brand = sender as! [String]
            print(category_brand[0])
            print(category_brand[1])
            category_brandVC.category_brand = category_brand[0]
            category_brandVC.category_brandName = category_brand[1]
            
        }
        
        if segue.identifier == "goToValueSeg" {
            let valueVC = segue.destination as! ValueViewController
            let userId = sender as! String
            valueVC.userId = userId
            
        }
        
        if segue.identifier == "goToProfileUserSeg" || segue.identifier == "goToProfileUserSeg_iPhoneSE"  {
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserVC.userId = userId
            
        }
        
        if segue.identifier == "goToHashTag_Seg" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
            
        }
    }
    
    @IBAction func more_TouchUpInside(_ sender: Any) {
        
        guard let _ = Api.User.CURRENT_USER?.uid else {
            self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            return}
        
        // create menu controller
        let menu = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        
        //EDIT ACTION
        let edit = UIAlertAction(title: "編集する", style: .default) { (UIAlertAction) -> Void in
            
            
            self.editPost()
            
        }
        
        // DELET ACTION
        let delete = UIAlertAction(title: "削除する", style: .default) { (UIAlertAction) -> Void in
            self.showAlert(title: "投稿を削除していいですか?", message: "", isComplain: false)
        }
        
        // COMPLAIN ACTION
        let complain = UIAlertAction(title: "通報する", style: .default) { (UIAlertAction) -> Void in
            print("complainPost")
            
            self.showAlert(title: "この投稿を通報していいですか？", message: "", isComplain: true)
        }
        
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        if self.post.uid == Api.User.CURRENT_USER!.uid && self.post.transactionStatus == Config.sell {
            menu.addAction(edit)
            menu.addAction(delete)
            menu.addAction(cancel)
        } else if self.post.uid != Api.User.CURRENT_USER!.uid  {
            menu.addAction(complain)
            menu.addAction(cancel)
        } else {
            menu.addAction(cancel)
        }
        
        
        
        // iPadでは必須！
        menu.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        menu.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    func deletePost() {
        Api.Post.deletePost(userId: self.currentUid, postId: self.post.id!, completion: {
            
            _ = self.navigationController?.popViewController(animated: true)
            
        })
    }
    
    func editPost() {
        
        SVProgressHUD.show()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            
            var array = [UIImage]()
            let imageUrls = self.post.imageUrls
            
            
            for imageUrl in imageUrls {
                let url = URL(string: imageUrl)
                if let data = try? Data(contentsOf: url!) {
                    let image: UIImage = UIImage(data: data)!
                    array.append(image)
                }
            }
            
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "EditPost_Seg", sender: array)
        }
    }
    
    func showAlert(title: String, message: String, isComplain: Bool) {
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let complainAction = UIAlertAction(title: "通報する", style: .default, handler: {(alert: UIAlertAction!) in
            guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
            let autoId = Api.Complain.REF_COMPLAINS.child(currentUid).childByAutoId().key
            Api.Complain.REF_COMPLAINS.child(currentUid).child(autoId!).setValue(["type": "post", "to": self.post.uid, "title": self.post.title, "caption": self.post.caption, "from": currentUid, "id": self.post.id])
            ProgressHUD.showSuccess("通報しました。")
        })
        
        let deleteAction = UIAlertAction(title: "削除する", style: .default, handler: {(alert: UIAlertAction!) in
            self.deletePost()
        })
        
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            
        })
        
        if isComplain {
            alert.addAction(complainAction)
            alert.addAction(cancelAction)
        } else {
            alert.addAction(deleteAction)
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
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if post.id == nil {
            return 0
        }
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            return 7
        case 6:
            return 1
        case 7:
            return 1
        case 8:
            return 1
        case 9:
            return 1
        case 10:
            return 1
        case 11:
            return self.comments.count
        case 12:
            return 1
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PageControlTableViewCell", for: indexPath) as! PageControlTableViewCell
            
            self.tableViewHeight = tableView.contentSize.height
            
            cell.pageControl.numberOfPages = post.imageCount!
            cell.pageControl.set(progress: self.currentPage, animated: true)
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell", for: indexPath) as! TitleTableViewCell
            cell.isBlocked = self.isBlocked
            cell.post = post
            cell.delegate = self
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaticTableViewCell1", for: indexPath) as! StaticTableViewCell1
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CaptionTableViewCell", for: indexPath) as! CaptionTableViewCell
            
            cell.post = post
            
            self.tableViewHeight = tableView.contentSize.height
            
            cell.captionTextView.addAttribute(.hashTag, attribute: .textColor(.blue))
            cell.captionTextView.delegate = self
            
            return cell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaticTableViewCell2", for: indexPath) as! StaticTableViewCell2
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductInfoTableViewCell", for: indexPath) as! ProductInfoTableViewCell
            
            let handler = {
                (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
                
                if substring == self.post.category2! {
                    print("label2 Tap")
                    self.performSegue(withIdentifier: "category_brand_Seg", sender: [Config.CATEGORY2, self.post.category2!])
                    
                } else if substring == self.post.brand! {
                    print("brand Tap")
                    self.performSegue(withIdentifier: "category_brand_Seg", sender: [Config.BRAND, self.post.brand!])
                }
            }
            
            if indexPath.row == 0 {
                cell.label1.text = "カテゴリ-"
                cell.label2.text = post.category2!
                cell.label2.setLinksForSubstrings([post.category2!], withLinkHandler: handler)
                
            } else if indexPath.row == 1 {
                cell.label1.text = "ブランド"
                if let brand = post.brand {
                    cell.label2.text = brand
                    cell.label2.setLinkForSubstring(brand, withLinkHandler: handler)
                } else {
                    cell.label2.text = "ー"
                }
                
            } else if indexPath.row == 2 {
                cell.label1.text = "商品の状態"
                cell.label2.text = post.status
            } else if indexPath.row == 3 {
                cell.label1.text = "配送料の負担"
                cell.label2.text = post.shipPayer
            } else if indexPath.row == 4 {
                cell.label1.text = "配送の方法"
                cell.label2.text = post.shipWay
            } else if indexPath.row == 5 {
                cell.label1.text = "配送日の目安"
                cell.label2.text = post.shipDeadLine
            } else if indexPath.row == 6 {
                cell.label1.text = "発送元の地域"
                cell.label2.text = post.shipFrom
            }
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaticTableViewCell3", for: indexPath) as! StaticTableViewCell3
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SellerTableViewCell", for: indexPath) as! SellerTableViewCell
            cell.usermodel = usermodel
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueTransactionTableViewCell", for: indexPath) as! ValueTransactionTableViewCell
            cell.usermodel = usermodel
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelfIntroTableViewCell", for: indexPath) as! SelfIntroTableViewCell
            cell.usermodel = usermodel
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaticTableViewCell4", for: indexPath) as! StaticTableViewCell4
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 11 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
            cell.delegate = self
            let comment = self.comments[indexPath.item]
            for usermod in self.usermodels {
                if self.comments[(indexPath.item)].uid == usermod.id {
                    cell.usermodel = usermod
                }
            }
            cell.comment = comment
            let estimatedSize = cell.commentTextView.sizeThatFits(cell.commentTextView.frame.size)
            commentTextViewHeight = estimatedSize.height - 11
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        } else if indexPath.section == 12 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllCommentTouchTableViewCell", for: indexPath) as! AllCommentTouchTableViewCell
            cell.isBlocked = self.isBlocked
            cell.delegate = self
            
            self.tableViewHeight = tableView.contentSize.height
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
            
        case 7:
            
            if let _ = Api.User.CURRENT_USER?.uid {
                
                if Config.isUnderIphoneSE {
                    performSegue(withIdentifier: "goToProfileUserSeg_iPhoneSE", sender: self.usermodel.id)
                    
                } else {
                    performSegue(withIdentifier: "goToProfileUserSeg", sender: self.usermodel.id)
                }
            } else {
                self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            }
        case 8:
            
            if let _ = Api.User.CURRENT_USER?.uid {
                performSegue(withIdentifier: "goToValueSeg", sender: post.uid)
            } else {
                self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
            }
        default:
            print("t")
        }
        
        
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return post.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photoUrlString = post.imageUrls[indexPath.item]
        let photoUrl = URL(string: photoUrlString)        
        cell.photo.sd_setImage(with: photoUrl)
        
        var widthCons = CGFloat()
        var dic: Dictionary<String, CGFloat> = post.ratios[indexPath.item]
        if dic[Config.ratioWidthKey]! > 1 {
            widthCons = view.frame.width / dic[Config.ratioWidthKey]!
            let padding = view.frame.width - widthCons
            return imageMargin(cell: cell, padding: padding, marginWhere: "side")
        }
        
        widthCons = view.frame.width / dic[Config.ratioHeightKey]!
        let padding = view.frame.width - widthCons
        return imageMargin(cell: cell, padding: padding, marginWhere: "top")
        
    }
    
    func imageMargin(cell: PhotoCollectionViewCell, padding: CGFloat, marginWhere: String) -> PhotoCollectionViewCell {
        
        if marginWhere == "side" {
            cell.topConstraint.constant = 0
            cell.bottomConstraint.constant = 0
            cell.leftSideConstraint.constant = padding / 2
            cell.rightSideConstraint.constant = padding / 2
        } else if (marginWhere == "top") {
            cell.topConstraint.constant = padding / 2
            cell.bottomConstraint.constant = padding / 2
            cell.leftSideConstraint.constant = 0
            cell.rightSideConstraint.constant = 0
        }
        
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DetailViewController: TitleTableViewCellDelegate {
    
    func goToRegisterUserVC() {
        self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
    }
    
    func goToCommentVC() {
        performSegue(withIdentifier: "CommentSegue", sender: post)
    }
}

extension DetailViewController: PurchaseViewControllerDelegate {
    
    func changePurchaseButton() {
        Api.Post.observePost(postId: postId) { (post) in
            
            if let post = post {
                self.post = post
                self.purchaseButton.isEnabled = false
                self.purchaseButton.backgroundColor = UIColor.lightGray
                self.purchaseButton.setTitle(self.SOLDOUT, for: UIControlState.normal)
                self.tableView.reloadData()
            }
            
        }
    }
}

extension DetailViewController: CommentViewControllerDelegate, CommentTableViewCellDelegate {
    func goToUIAlertController(post: Post?, currentUid: String, comment: Comment?) {
        print("t")
    }
    
    func goToRegisterVC() {
        self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
        
    }
    
    func goToProfileUser(userId: String) {
        if Config.isUnderIphoneSE {
            performSegue(withIdentifier: "goToProfileUserSeg_iPhoneSE", sender: userId)
            
        } else {
            performSegue(withIdentifier: "goToProfileUserSeg", sender: userId)
        }
        
    }
    
    func reloadDetailVC() {
        fetchAllUsers {
            self.observePost()
        }
    }
}


extension DetailViewController: RegeributedTextViewDelegate {
    func regeributedTextView(_ textView: RegeributedTextView, didSelect text: String, values: [String : Any]) {
        print("Selected word: \(text)")
        self.performSegue(withIdentifier: "goToHashTag_Seg", sender: text)
        // You can get the emmbeded url from values
        if let url = values["URL"] as? String {
            // e.g.
            // UIApplication.shared.openURL(URL(string: url)!)
        }
    }
}

extension DetailViewController: EditPostViewControllerDelegate {
    func updatePost() {
        self.observePost()
    }
}
