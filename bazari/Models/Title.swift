//
//  Title.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/03.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
class Title {
    var titleWord: String?
    var timestamp: Int?
}

extension Title {
    static func transformTitle(dict: [String: Any], key: String) -> Title {
        let title = Title()
        title.titleWord = key
        title.timestamp = dict["timestamp"] as? Int
        return title
    }
}
