//
//  Card.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/09/30.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation


class Card {
    var id: String?
    var cardType: String?
    var deletedFlg: Bool?
    
    static func transformCard(dict: [String: Any], key: String) -> Card {
        let card = Card()
        card.id = key
        card.cardType = dict["cardType"] as? String
        card.deletedFlg = dict["deletedFlg"] as? Bool
        return card
    }
    
}
