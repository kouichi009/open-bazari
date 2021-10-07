//
//  PostPhotoCollectionViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/10.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol PostPhotoCollectionViewCellDelegate {
    func photoPick(indexRow: Int)
    func removePick(indexRow: Int)
}

class PostPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var leftSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightSideConstraint: NSLayoutConstraint!
    
    
    var indexRow = Int()
    
    var photoImage: UIImage?
    
    
    
    var delegate : PostPhotoCollectionViewCellDelegate?
    
    @IBAction func rotate(_ sender: Any) {
        
        photoImage = imageRotatedByDegrees(oldImage: photoImage!, deg: 90)
     
        
    }
    
    @IBAction func close(_ sender: Any) {
        delegate?.removePick(indexRow: indexRow)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(tapGestureForPhoto)
        photo.isUserInteractionEnabled = true
    }
    
    @objc func photo_TouchUpInside() {
        print("PHotoPICK")

        delegate?.photoPick(indexRow: self.indexRow)
    }
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
