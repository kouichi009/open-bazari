//
//  StripeTools.swift
//  Stripe0928CodeMentor
//
//  Created by koichi nakanishi on H30/09/29.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import Stripe

struct StripeTools {
    
    //store stripe secret key // サーバー側のキー
    private var stripeSecret = Config.StripeSecretKeyForServer
    
    //generate token each time you need to get an api call
    func generateToken(card: STPCardParams, completion: @escaping (_ token: STPToken?) -> Void) {
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                completion(token)
            }
            else {
                print(error)
                completion(nil)
            }
        }
    }
    
    func getBasicAuth() -> String{
        return "Bearer \(self.stripeSecret)"
    }
    
}
