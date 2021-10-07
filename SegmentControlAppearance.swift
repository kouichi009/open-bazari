//
//  SegmentControlAppearance.swift
//  BudgeSegmentTestNakanishi
//
//  Created by koichi nakanishi on H30/07/27.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import UIKit
import BadgeSegmentControl

class SegmentControlAppearance: NSObject {
    
    
    class func appearance() -> BadgeSegmentControlAppearance {
        let appearance = BadgeSegmentControlAppearance()
        
        let selectedColor = UIColor(red:255/255, green:61/255, blue:58/255, alpha:1.00)

        
        // Segment color
        appearance.segmentOnSelectionColour = selectedColor
        appearance.segmentOffSelectionColour = UIColor.white
        
        // Title font
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 14)
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 14)
        
        // Title color
        appearance.titleOnSelectionColour = UIColor.white
        appearance.titleOffSelectionColour = selectedColor
        
        // Vertical margin
      //  appearance.contentVerticalMargin = 10.0
        
        // Border style
        appearance.borderColor = selectedColor
        appearance.cornerRadius = 5.0
        appearance.borderWidth = 2.0
        
        // Divider style
        appearance.dividerWidth = 1.0
        appearance.dividerColour = selectedColor
        
        return appearance
    }
}
