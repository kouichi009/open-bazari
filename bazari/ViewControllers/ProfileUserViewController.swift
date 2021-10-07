//
//  ProfileUserViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SVProgressHUD
import Toaster


class ProfileUserViewController: UIViewController {
    
    var posts = [Post]()
    var usermodel: UserModel?
    var userId : String?
    var page = 0
    var increaseNum = 0
    var pullFlg = false
    var reloadAllPostFlg = false
    var underPagePostFlg = false
    
    var myPostCount = 0
    
    var isBlocked = false
    var currentUid = String()
    
    var firstCallFlg = false
    
    let refreshControl = UIRefreshControl()
    var defaultHeight: CGFloat?
    var textHeight: CGFloat? {
        
        didSet {
            updateTextHeight()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func updateTextHeight() {
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        self.collectionView?.addSubview(refreshControl)
        
        self.page = Config.page
        self.increaseNum = Config.page
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.alwaysBounceVertical = true
        
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
            observeUsers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    func observeUsers() {
        Api.User.observeUser(withId: currentUid) { (usermodel) in
            
            if let usermodel = usermodel {
                if let blocks = usermodel.blocks {
                    
                    blocks.forEach({ (block) in
                        
                        if self.userId == block.key {
                            self.isBlocked = true
                        }
                    })
                }
            }
            
            Api.User.observeUser(withId: self.userId!) { (usermodel) in
                
                //データなし
                if usermodel == nil {
                    ToastView.appearance().cornerRadius = 10
                    ToastView.appearance().backgroundColor = .gray
                    ToastView.appearance().bottomOffsetPortrait = 100
                    ToastView.appearance().font = .systemFont(ofSize: 16)
                    Toast(text: "データがありませんでした。").show()
                    _ = self.navigationController?.popViewController(animated: true)
                    return;
                    
                }
                
                if let usermodel = usermodel {
                    self.isFollowing(userId: (usermodel.id)!, completed: { (value) in
                        usermodel.isFollowing = value
                        self.usermodel = usermodel
                        
                        if !self.firstCallFlg {
                            self.fetchPosts(userId: usermodel.id!)
                            self.firstCallFlg = true
                        } else {
                            self.collectionView.reloadData()
                        }
                    })
                }
                
            }
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    @objc func refresh() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
//        fetchPosts(userId: (self.usermodel?.id)!)
    }
    
    func fetchPosts(userId: String) {
        
        
        Api.MyPosts.fetchCountMyPosts(userId: userId) { (myAllPostCount) in
            self.myPostCount = myAllPostCount
            self.posts.removeAll()
            self.collectionView.reloadData()
            
            var count = 0
            Api.MyPosts.fetchMyPosts(userId: userId, page: self.page, completion: { (post, myPostCount) in
                
                count += 1
                
                if let post = post {
                self.posts.append(post)
                }
                    
                if count == myPostCount {
                    self.collectionView.reloadData()
                }
                    
            })
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.posts.count == 0 {
            return;
        }
        
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        
        //pullRation 0.1 - 1.0
        if pullRatio >= 0.1 && !pullFlg {
            self.pullFlg = true
            self.loadMorePosts()
        }
        
        if pullRatio == 0.0 {
            self.pullFlg = false
            
        }
        print("pullRation:\(pullRatio)")
    }
    
    
    func loadMorePosts() {
        
        if underPagePostFlg {
            
            if self.posts.count >= self.page {
                underPagePostFlg = false
            }
            return;
        }
        
        
        //prePage
        var prepage = page
        
        var count = 0
        
        // increase page size
        page = page + increaseNum
        
        
        
        Api.MyPosts.fetchMyPosts(userId: (self.usermodel?.id)!, page: self.page, completion: { (post, postCount) in
            
            
            if prepage >= postCount {
                self.page = postCount
                prepage = postCount
                self.reloadAllPostFlg = true
                return;
            }
            
            if self.reloadAllPostFlg {
                
                ProgressHUD.show("少々おまちください。")
                count += 1
                
                if count == 1 {
                    self.posts.removeAll()
                }
                
                if let post = post {
                    self.posts.append(post)
                }
            
                if postCount == count {
                    
                    self.collectionView?.reloadData()
                    ProgressHUD.showSuccess("読み込み完了")
                    self.reloadAllPostFlg = false
                    return;
                } else {
                    return;
                }
            }
            
            SVProgressHUD.show()
            
            
            count += 1
        
            if count > prepage {
                
                if let post = post {
                    self.posts.append(post)
                }
            }
            
            if count == postCount {
                self.collectionView?.reloadData()
                SVProgressHUD.dismiss()
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let post = sender as? Post
            detailVC.postId = (post?.id)!
            
        }
        
        if segue.identifier == "goToValueVC_Seg" {
            let valueVC = segue.destination as! ValueViewController
            let userId  = sender as! String
            valueVC.userId = userId
        }
        
        if segue.identifier == "goToProfileEdit_Seg" {
            let profileEditVC = segue.destination as! ProfileEditTableViewController
            profileEditVC.delegate = self
        }
    }
    
    @IBAction func more_TouchUpInside(_ sender: Any) {
        
        let menu = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        
        
        var block = UIAlertAction()
        
        if isBlocked {
            block = UIAlertAction(title: "ユーザーブロックを解除する", style: .default) { (UIAlertAction) -> Void in
                
                self.showAlert(title: "このユーザーのブロックを解除してもいいですか？", message: "", blockFlg: false)
            }
        } else {
            // BLOCK ACTION
            block = UIAlertAction(title: "ユーザーブロックする", style: .default) { (UIAlertAction) -> Void in
                
                self.showAlert(title: "このユーザーをブロックしてもいいですか？", message: "", blockFlg: true)
            }
        }
        
        let editProfile = UIAlertAction(title: "プロフィールを編集する", style: .default) { (UIAlertAction) -> Void in
            
            self.performSegue(withIdentifier: "goToProfileEdit_Seg", sender: nil)
            
        }
        
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        
        
        if self.userId != currentUid {
            
            menu.addAction(block)
            menu.addAction(cancel)
        } else {
            menu.addAction(editProfile)
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
    
    
    func showAlert(title: String, message: String, blockFlg: Bool) {
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        
        var blockAction = UIAlertAction()
        if blockFlg == true {
            blockAction = UIAlertAction(title: "ブロックする", style: .default, handler: {(alert: UIAlertAction!) in
                ToastView.appearance().cornerRadius = 10
                ToastView.appearance().backgroundColor = .gray
                ToastView.appearance().bottomOffsetPortrait = 100
                ToastView.appearance().font = .systemFont(ofSize: 16)
                Toast(text: "ブロックしました。").show()
                self.blockUser()
            })
        } else {
            blockAction = UIAlertAction(title: "ブロックを解除する", style: .default, handler: {(alert: UIAlertAction!) in
                ToastView.appearance().cornerRadius = 10
                ToastView.appearance().backgroundColor = .gray
                ToastView.appearance().bottomOffsetPortrait = 100
                ToastView.appearance().font = .systemFont(ofSize: 16)
                Toast(text: "ブロックを解除しました").show()
                self.unBlockUser()
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(blockAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func blockUser() {
        
        Api.Block.REF_BLOCKED.child((usermodel?.id)!).updateChildValues([currentUid: true])
        Api.User.REF_USERS.child(currentUid).child("blocks").updateChildValues([(usermodel?.id)!: true]) { (error, ref) in
            self.observeUsers()
        }
    }
    
    func unBlockUser() {
        self.isBlocked = false
        Api.Block.REF_BLOCKED.child((usermodel?.id)!).child(currentUid).removeValue()
        Api.User.REF_USERS.child(currentUid).child("blocks").child((usermodel?.id)!).removeValue { (error, raf) in
            
            self.observeUsers()
        }
    }
    
    func imageMargin(cell: PostCollectionViewCell, padding: CGFloat, marginWhere: String) -> PostCollectionViewCell {
        
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

extension ProfileUserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell

        cell.post = posts[indexPath.row]
        
        var widthCons = CGFloat()
        var cellWidth =  (collectionView.frame.size.width / 2 - 1)
        var dic: Dictionary<String, CGFloat> = (cell.post?.thumbnailRatio)!
        if dic[Config.ratioWidthKey]! > 1 {
            widthCons = cellWidth / dic[Config.ratioWidthKey]!
            let padding = cellWidth - widthCons
            return imageMargin(cell: cell, padding: padding, marginWhere: "side")
        }
        
        widthCons = cellWidth / dic[Config.ratioHeightKey]!
        let padding = cellWidth - widthCons
        return imageMargin(cell: cell, padding: padding, marginWhere: "top")
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        headerViewCell.selfIntroTextView.placeholder = "自己紹介文がまだ記入されていません。"
        headerViewCell.myPostCount = self.myPostCount
        if let usermodel = self.usermodel {
            headerViewCell.isBlocked = self.isBlocked
            headerViewCell.usermodel = usermodel
        }
        
        headerViewCell.delegate = self
        defaultHeight = headerViewCell.defaultHeight
        return headerViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ビュー遷移時にタブバーを隠して、戻ってきたらタブバーを再表示させる方法
        self.performSegue(withIdentifier: "DetailSegue", sender: self.posts[indexPath.item])
    }
    
}

extension ProfileUserViewController: HeaderProfileCollectionReusableViewDelegate {
    
    func goToValueVC(userId: String) {
        self.performSegue(withIdentifier: "goToValueVC_Seg", sender: userId)
    }
    
    func changeTextViewHeight(height: CGFloat?) {
        textHeight = height
    }
    
    func unBlockAlert(title: String, message: String, blockFlg: Bool) {
        self.showAlert(title: title, message: message, blockFlg: blockFlg)
    }
}

extension ProfileUserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        print("defaultHeight \(defaultHeight)")
        print("textHeight \(textHeight)")
        
        if defaultHeight != nil && textHeight != nil {
            
            return CGSize(width: self.collectionView.contentSize.width, height: 268 - defaultHeight! + textHeight!)
        }
        
        return CGSize(width: self.collectionView.contentSize.width, height: 268)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 1, height: (collectionView.frame.size.width / 2 - 1) + 76)
    }
}

extension ProfileUserViewController: ProfileEditTableViewControllerDelegate {
    func updateProfile() {
        
        self.observeUsers()
    }
}

