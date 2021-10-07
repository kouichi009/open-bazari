//
//  SearchViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/02.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import SHSearchBar
import SVProgressHUD

protocol SearchViewControllerDelegate {
    func callCancel()
}

class SearchViewController: UIViewController, SHSearchBarDelegate {
    
    var resultStr = String()
    var searchBar: SHSearchBar!
    var rasterSize: CGFloat = 11.0
    let searchbarHeight: CGFloat = 44.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var colletionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var uiViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelOnUIView: UILabel!
    
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    var currentUid = String()
    
    var searchKeywords = [String]()
    var allTitleStrs = [String]()
    var selectedTitleStrs = [String]()
    
    var resultPosts = [Post]()
    var selectedPosts = [Post]()
    
    let loadKeywordCount = 60
    var pageForTable = 0
    
    var page = 0
    var increaseNum = 0
    var pullFlg = false
    var underPagePostFlg = false
    
    var callhereFlg = false
    
    var noMoreFlg = false
    
    let refreshControl = UIRefreshControl()
    
    var tapSerchButtonFlg = false
    let userDefaults = UserDefaults.standard
    let seachKeywordKey = "searchKeyword"
    
    var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        pageForTable = loadKeywordCount
        page = Config.page
        increaseNum = Config.increaseNum
        
        if let currentUid = Api.User.CURRENT_USER?.uid {
            self.currentUid = currentUid
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setSearch()
        
        setCollectionView()
        
        loadTitles_Posts()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.callCancel()
    }
    
    
    func loadTitles_Posts() {
        var count = 0
        var titleStrs = [String]()
        
        Api.Post.observeAllPosts { (post, postCount) in
            
            count += 1
            
            if let post = post {
                titleStrs.append(post.title!)
                
                if (post.title?.contains(self.resultStr))! || (post.caption?.contains(self.resultStr))! {
                    self.resultPosts.append(post)
                }
            }
            
            if count == postCount {
                
                //重複した要素を消す
                let orderSet = NSOrderedSet(array: titleStrs)
                self.allTitleStrs = orderSet.array as! [String]
                self.selectedPosts = self.resultPosts.prefix(self.page).map {$0}
                self.callhereFlg = true
                self.tableView.reloadData()
                self.collectionView.reloadData()
                
                print(self.resultPosts.count)
                if self.resultPosts.count == 0 {
                    self.setUIView()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tapSerchButtonFlg = false
        loadMyHistoryKeyword()
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
        
        labelOnUIView.isHidden = true
      //  uiViewHeightConstraint.constant = 0
        tableViewHeightConstraint.constant = 0
        colletionViewHeightConstraint.constant = self.view.frame.height
        self.collectionView.reloadData()
    }
    
    func setTableView() {
        
        labelOnUIView.isHidden = true
//        uiViewHeightConstraint.constant = 0
        tableViewHeightConstraint.constant = self.view.frame.height
        colletionViewHeightConstraint.constant = 0
        self.tableView.reloadData()
    }
    
    func setUIView() {
        labelOnUIView.isHidden = false
  //      uiViewHeightConstraint.constant = self.view.frame.height
        tableViewHeightConstraint.constant = 0
        colletionViewHeightConstraint.constant = 0
        //    self.tableView.reloadData()
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
        
        searchBar.text = resultStr
    }
    
    func searchBarDidBeginEditing(_ searchBar: SHSearchBar) {
        setTableView()
        
        if searchBar.text == "" {
            self.selectedTitleStrs.removeAll()
            self.tableView.reloadData()
        } else {
            
            self.selectedTitleStrs.removeAll()
            self.tableView.reloadData()
            allTitleStrs.forEach { (titleStr) in
                
                if titleStr.contains(searchBar.text!) {
                    self.selectedTitleStrs.append(titleStr)
                }
            }
            self.tableView.reloadData()
        }
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
        
        tapSerchButtonFlg = true
        
        var count = 0
        for searchKeyword in searchKeywords {
            
            if searchKeyword == text {
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
        self.performSegue(withIdentifier: "goToSearch_Seg", sender: searchBar.text!)
        
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("selectPosts ", selectedPosts.count)
        print(Config.page)
        if self.selectedPosts.count < self.page  {
            return;
        }
        
        if noMoreFlg {
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
        //    print("pullRation:\(pullRatio)")
    }
    
    func loadMorePosts() {
        
        //prePage
        var prepage = page
        
        // increase page size
        page = page + increaseNum
        
        if prepage >= selectedPosts.count {
            page = selectedPosts.count
            
            self.selectedPosts = resultPosts
            
            self.collectionView.reloadData()
            noMoreFlg = true
            
            return;
        }
        
        
        
        SVProgressHUD.show()
        
        self.selectedPosts = self.resultPosts.prefix(self.page).map {$0}
        
        self.collectionView.reloadData()
        SVProgressHUD.dismiss()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch_Seg" {
            let searchVC = segue.destination as! SearchViewController
            let resultStr = sender as! String
            searchVC.resultStr = resultStr
            searchVC.delegate = self
        }
        
        if segue.identifier == "DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let post = sender as? Post
            detailVC.postId = (post?.id)!
            
            
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0 {
            return 1
        } else if section == 1 {
            if self.searchBar.text != "" {
                return self.selectedTitleStrs.count
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
        print(indexPath.row)
        
        if indexPath.section == 1 {
            if selectedTitleStrs.count == 0 {
                self.performSegue(withIdentifier: "goToSearch_Seg", sender:  searchKeywords[indexPath.row])
            } else {
                self.performSegue(withIdentifier: "goToSearch_Seg", sender:  selectedTitleStrs[indexPath.row])
            }
        }
    }
    
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        
        
        cell.post = self.selectedPosts[indexPath.item]
        var cellWidth =  (collectionView.frame.size.width / 2 - 1)
        print("indexItem ", indexPath.item)
      //  var widCons: CGFloat = cellWidth / (cell.post?.ratios[0])!
        
//        let padding = cellWidth - widCons
//        
//        if padding <= 0 {
//            cell.rightSideConstraint.constant = 0
//            cell.leftSideConstraint.constant = 0
//        } else {
//            cell.rightSideConstraint.constant = padding / 2
//            cell.leftSideConstraint.constant = padding / 2
//        }
//        
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //ビュー遷移時にタブバーを隠して、戻ってきたらタブバーを再表示させる方法
        self.performSegue(withIdentifier: "DetailSegue", sender: self.selectedPosts[indexPath.item])
    }
}


extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
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

extension SearchViewController: SearchViewControllerDelegate, KeywordTableViewCellDelegate {
    
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
        DispatchQueue.main.async {
            self.searchBar.text = ""
        }
        if self.resultPosts.count == 0 {
            self.setUIView()
        } else {
            setCollectionView()
        }
    }
}

