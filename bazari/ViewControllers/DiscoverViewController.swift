//
//  DiscoverViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/02.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SHSearchBar
import IQKeyboardManagerSwift


class DiscoverViewController: UIViewController, SHSearchBarDelegate {
    
    let category1Strs = ["スマートフォン/携帯電話","スマホアクセサリー","PC/タブレット","カメラ","テレビ/映像機器","オーディオ機器","美容/健康","冷暖房/空調","調理家電","生活家電","スマホ/家電/カメラ その他"]
    
    var searchBar: SHSearchBar!
    var rasterSize: CGFloat = 11.0
    let searchbarHeight: CGFloat = 44.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var colletionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    var searchKeywords = [String]()
    var allTitleStrs = [String]()
    var selectedTitleStrs = [String]()
    
    let loadKeywordCount = 60
    var pageForTable = 0

    let refreshControl = UIRefreshControl()
    
    var tapSerchButtonFlg = false
    var callhereFlg = false
    
    let userDefaults = UserDefaults.standard
    let seachKeywordKey = "searchKeyword"
    var currentUid = String()
    
    var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        pageForTable = loadKeywordCount
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        
        setSearch()
        setCollectionView()
        
        loadTitles()
        
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print(notification)
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.bottomTableViewConstraint.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
            
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomTableViewConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        }
    }
    
    func loadTitles() {
        var count = 0
        var titleStrs = [String]()
        Api.Post.fetchCountPost { (postCount) in
            
            Api.Post.observePostsAdded(completion: { (post) in
                
                if self.callhereFlg {
                    
                    if let post = post {
                        self.allTitleStrs.insert(post.title!, at: 0)
                    }
                    //重複した要素を消す
                    let orderSet = NSOrderedSet(array: self.allTitleStrs)
                    self.allTitleStrs = orderSet.array as! [String]
                    self.tableView.reloadData()
                    return;
                }
                count += 1
            
                if let post = post {
                    titleStrs.insert(post.title!, at: 0)
                }

                if count == postCount {
                    
                    //重複した要素を消す
                    let orderSet = NSOrderedSet(array: titleStrs)
                    self.allTitleStrs = orderSet.array as! [String]
                    self.callhereFlg = true
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
    func loadMyHistoryKeyword() {
        
        let keywords = userDefaults.array(forKey: seachKeywordKey) as? [String]
        
        print(keywords?.count)
        if let keywords = keywords {
            searchKeywords = keywords.prefix(self.pageForTable).map {$0}
            print(searchKeywords.count)
            searchKeywords.forEach { (searchKey) in
                print("sea ", searchKey)
            }
            self.tableView.reloadData()
        }
    }

    func setCollectionView() {
        
        //     searchBar.text = NSLocalizedString("", comment: "")
        tableViewHeightConstraint.constant = 0
        colletionViewHeightConstraint.constant = self.view.frame.height
        self.collectionView.reloadData()
    }
    
    func setTableView() {
        
        tableViewHeightConstraint.constant = self.view.frame.height
        colletionViewHeightConstraint.constant = 0
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        tapSerchButtonFlg = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        loadMyHistoryKeyword()
        
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
    
    func searchBarDidBeginEditing(_ searchBar: SHSearchBar) {
        setTableView()
    }
    
    func searchBarShouldCancel(_ searchBar: SHSearchBar) -> Bool {
        print("cancelClick")
        setCollectionView()
        
        DispatchQueue.main.async {
            self.searchBar.text = ""
        }
        return true
    }
    
    func searchBar(_ searchBar: SHSearchBar, textDidChange text: String) {
        
        print("text \(text)")
        
        
        if text == "" {
            self.selectedTitleStrs.removeAll()
            self.tableView.reloadData()
        } else {
            
            self.selectedTitleStrs.removeAll()
            self.tableView.reloadData()
            allTitleStrs.forEach { (titleStr) in
                
                if titleStr.contains(text) {
                    self.selectedTitleStrs.append(titleStr)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarShouldReturn(_ searchBar: SHSearchBar) -> Bool {
        
        var text = searchBar.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if text == "" {
            return true;
        }
        
        if tapSerchButtonFlg {
            return true;
        }
//
        tapSerchButtonFlg = true
        
        var count = 0
        for searchKeyword in searchKeywords {
            
            if searchKeyword == text {
//                searchKeywords[count] = searchKeyword
                searchKeywords.remove(at: count)
                searchKeywords.insert(searchKeyword, at: 0)
                userDefaults.set(searchKeywords, forKey: seachKeywordKey)
                self.performSegue(withIdentifier: "goToSearch_Seg", sender: text!)
                return true;
            }
            count += 1
        }
        
        searchKeywords.insert(text!, at: 0)
        userDefaults.set(searchKeywords, forKey: seachKeywordKey)
  
        self.performSegue(withIdentifier: "goToSearch_Seg", sender: text!)
        
        return true
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
        //    config.cancelButtonTitle = NSLocalizedString("sbe.general.cancel", comment: "")
        config.cancelButtonTextAttributes = [.foregroundColor : UIColor.darkGray]
        config.textContentType = UITextContentType.fullStreetAddress.rawValue
        config.textAttributes = [.foregroundColor : UIColor.gray]
        return config
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch_Seg" {
            let searchVC = segue.destination as! SearchViewController
            let resultStr = sender as! String
            searchVC.resultStr = resultStr
            searchVC.delegate = self
        }
        
        if segue.identifier == "goToCategorySeg" {
            let categoryVC = segue.destination as! CategoryPostsViewController
            let categoryStr = sender as! String
            categoryVC.category1 = categoryStr
            
        }
        
        if segue.identifier == "goToFollowSeg" {
            let followPostsVC = segue.destination as! FollowPostsViewController
            let userId = sender as! String
            followPostsVC.userId = userId
            
        }
    }
    
}

extension DiscoverViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0 {
            return 1
        } else if section == 1 {
            if self.searchBar.text != "" {
                return selectedTitleStrs.count
            } else {
                return searchKeywords.count
            }
        }
        
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "KeywordCell0TableViewCell") as! KeywordCell0TableViewCell
            if searchBar.text == "" {
                cell.label1.text = "最近検索したワード"
            } else {
                cell.label1.text = ""
            }
            return cell
            
        case 1:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "KeywordTableViewCell") as! KeywordTableViewCell
            
            if searchBar.text == "" {
                cell.searchKeyword = self.searchKeywords[indexPath.row]
                cell.closeImageView.isHidden = false
            } else {
                cell.titleStr = self.selectedTitleStrs[indexPath.row]
                cell.closeImageView.isHidden = true
            }
            
            cell.delegate = self
            
            return cell
            
        default:
            print("t")
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedTitleStrs.count == 0 {
            self.performSegue(withIdentifier: "goToSearch_Seg", sender:  searchKeywords[indexPath.row])
        } else {
            self.performSegue(withIdentifier: "goToSearch_Seg", sender:  selectedTitleStrs[indexPath.row])
        }
        
    
        
        
       
    }
    
}

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! DiscoverCollectionViewCell
        
        switch indexPath.item {
        case 0:
            cell.imageView.image = #imageLiteral(resourceName: "phoneBack")
        case 1:
            cell.imageView.image = #imageLiteral(resourceName: "phoneCaseBack")
        case 2:
            cell.imageView.image = #imageLiteral(resourceName: "PCBack")
        case 3:
            cell.imageView.image = #imageLiteral(resourceName: "cameraBack")
        case 4:
            cell.imageView.image = #imageLiteral(resourceName: "tvBack")
        case 5:
            cell.imageView.image = #imageLiteral(resourceName: "audioBack")
        case 6:
            cell.imageView.image = #imageLiteral(resourceName: "beautyBack")
        case 7:
            cell.imageView.image = #imageLiteral(resourceName: "airConditionBack")
        case 8:
            cell.imageView.image = #imageLiteral(resourceName: "cookBack")
        case 9:
            cell.imageView.image = #imageLiteral(resourceName: "liveBack")
        case 10:
            cell.imageView.image = #imageLiteral(resourceName: "sonotaBack")
        case 11:
            cell.imageView.image = #imageLiteral(resourceName: "followBack")
            
        default:
            print("t")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ビュー遷移時にタブバーを隠して、戻ってきたらタブバーを再表示させる方法
        
        if indexPath.item == 11 {
            
            if let _ = Api.User.CURRENT_USER?.uid {
                self.performSegue(withIdentifier: "goToFollowSeg", sender: currentUid)
            }
        } else {
        
        var category1 = category1Strs[indexPath.item]
        let arrCharacterToReplace = ["/"," "]
        for character in arrCharacterToReplace{
            
            if (category1.contains(character)) {
                category1 = category1.replacingOccurrences(of: character, with: "")
            }
        }
        self.performSegue(withIdentifier: "goToCategorySeg", sender: category1)
    }
    }
}


extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 1, height: (collectionView.frame.size.width / 2 - 1) / 2)
    }
}

extension DiscoverViewController: SearchViewControllerDelegate, KeywordTableViewCellDelegate {
  
    func deleteKeyword(keyword: String?) {
        if let keyword = keyword {
            
            var count = 0
            for searchKeyword in searchKeywords {
                
                if searchKeyword == keyword {
                    searchKeywords.remove(at: count)
                    userDefaults.set(searchKeywords, forKey: seachKeywordKey)
                    self.tableView.reloadData()
                }
                count += 1
            }
        }
    }
    
    func callCancel() {
        selectedTitleStrs.removeAll()
        setCollectionView()
        DispatchQueue.main.async {
            self.searchBar.text = ""
        }
    }
}
