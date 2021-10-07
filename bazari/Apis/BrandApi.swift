//
//  BrandApi.swift
//  bazari
//
//  Created by koichi nakanishi on H30/10/28.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class BrandApi {
    let REF_BRAND_CANDIDATES = Database.database().reference().child("brandCandidates")
}
