//
//  TabBarContentView.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/24.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class TabBarContentView: ESTabBarItemContentView {

    public var duration = 0.3
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let selectedColor = UIColor(red:255/255, green:61/255, blue:58/255, alpha:1.00)
        
        //define the text label and icon color for normal and highlighted mode.
        textColor = UIColor(red:0.38, green:0.49, blue:0.55, alpha:1.0) //Or whatever color you want
        highlightTextColor = selectedColor ////Or whatever color you want
        iconColor = UIColor(red:0.38, green:0.49, blue:0.55, alpha:1.0) //Or whatever color you want
        highlightIconColor = selectedColor ////Or whatever color you want
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
//        self.bounceAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
//        self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }

}
