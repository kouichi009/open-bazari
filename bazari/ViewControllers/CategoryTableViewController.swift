//
//  Category1TableViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/04.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol CategoryTableViewControllerDelegate {
    func categoryType(category: String)
}

class CategoryTableViewController: UITableViewController {
    
    var selectedCategoryStr: String?
    var categoryForDatabaseStr: String?
    var newPostVC: NewPostViewController?
    var editPostVC: EditPostViewController?
    var draftToNewPostVC : DraftToNewPostViewController?
    var redIndex: Int?
    
    var delegate: CategoryTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let selectedCategoryStr = selectedCategoryStr {
            
            var count = 0
            Config.categories.forEach { (categoryStr) in
                
                categoryForDatabaseStr = categoryStr
                let arrCharacterToReplace = ["/"," "]
                for character in arrCharacterToReplace{
                    
                    if (categoryForDatabaseStr?.contains(character))! {
                        categoryForDatabaseStr = categoryForDatabaseStr?.replacingOccurrences(of: character, with: "")
                    }
                }

                if selectedCategoryStr == categoryForDatabaseStr {
                    redIndex = count
                }
                count += 1
                
            }
            
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryForDatabaseStr = Config.categories[indexPath.row]
        let arrCharacterToReplace = ["/"," "]
        for character in arrCharacterToReplace{
            
            if (categoryForDatabaseStr?.contains(character))! {
                categoryForDatabaseStr = categoryForDatabaseStr?.replacingOccurrences(of: character, with: "")
            }
        }
        delegate?.categoryType(category: categoryForDatabaseStr!)
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Config.categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        
        if let redIndex = self.redIndex {
            if redIndex == indexPath.row {
                cell.titleLbl.textColor = UIColor.red
            }
        }
        cell.titleLbl.text = Config.categories[indexPath.row]
        return cell
    }
 
    
}
