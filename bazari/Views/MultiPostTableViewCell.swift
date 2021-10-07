//
//  MultiPostTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class MultiPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let itemSize = UIScreen.main.bounds.width / 4 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        collectionView.collectionViewLayout = layout
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
