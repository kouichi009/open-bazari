//
//  BaseTabBar.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/24.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

class BaseTabBar: UITabBar {

    static var dotColor: UIColor = UIColor.red
    static var dotSize: CGFloat = 4
    static var dotPositionX: CGFloat = 0.8
    static var dotPositionY: CGFloat = 0.2
    
    var dotMap = [Int: Bool]()
    
    func resetDots() {
        dotMap.removeAll()
    }
    
    func addDot(tabIndex: Int) {
        dotMap[tabIndex] = true
    }
    
    func removeDot(tabIndex: Int) {
        dotMap[tabIndex] = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let items = items {
            for i in 0..<items.count {
                let item = items[i]
                if let view = item.value(forKey: "view") as? UIView, let dotBoolean = dotMap[i], dotBoolean == true {
                    let x = view.frame.origin.x + view.frame.width * BaseTabBar.dotPositionX
                    let y = view.frame.origin.y + view.frame.height * BaseTabBar.dotPositionY
                    let dotPath = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: BaseTabBar.dotSize, height: BaseTabBar.dotSize))
                    BaseTabBar.dotColor.setFill()
                    dotPath.fill()
                }
            }
        }
    }
    
}
