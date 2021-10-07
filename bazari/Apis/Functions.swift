//
//  Functions.swift
//  bazari
//
//  Created by koichi nakanishi on H30/12/30.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation

class Functions {
    
    static func formatPrice(price: Int) -> String {
        var formattedNumber = String()
        //数字にカンマ,をつける
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        formattedNumber = numberFormatter.string(from: NSNumber(value: price))!
        return formattedNumber
    }
}
