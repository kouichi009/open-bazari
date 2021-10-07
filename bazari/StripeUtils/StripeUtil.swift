//
//  StripeUtil.swift
//  Stripe0928CodeMentor
//
//  Created by koichi nakanishi on H30/09/29.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import Foundation
import Stripe
import SVProgressHUD

class StripeUtil {
    var stripeTool = StripeTools()
    var customerId: String?
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    
    
    //createUser
    func createUser(card: STPCardParams, completion: @escaping (_ success: Bool) -> Void) {
        
        //Stripe iOS SDK will gave us a token to make APIs call possible
        stripeTool.generateToken(card: card) { (token) in
            if(token != nil) {
                
                //request to create the user
                let request = NSMutableURLRequest(url: URL(string: "https://api.stripe.com/v1/customers")!)
                
                //params array where you can put your user informations
                var params = [String:String]()
                
                guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
                let uidEmail = currentUid + "@gmail.com"
                    params["email"]  = uidEmail
                    
                    //transform this array into a string
                    var str = ""
                    params.forEach({ (key, value) in
                        str = "\(str)\(key)=\(value)&"
                    })
                    
                    //basic auth
                    request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
                    
                    //POST method, refer to Stripe documentation
                    request.httpMethod = "POST"
                    
                    request.httpBody = str.data(using: String.Encoding.utf8)
                    
                    //create request block
                    self.dataTask = self.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
                        
                        //get returned error
                        if let error = error {
                            print(error)
                            completion(false)
                        }
                        else if let httpResponse = response as? HTTPURLResponse {
                            //you can also check returned response
                            if(httpResponse.statusCode == 200) {
                                if let data = data {
                                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                                    //serialize the returned datas an get the customerId
                                    if let id = json["id"] as? String {
                                        self.customerId = id
                                        self.createCard(stripeId: id, card: card) { (success) in
                                            completion(true)
                                        }
                                    }
                                }
                            }
                            else {
                                completion(false)
                            }
                        }
                    }
                    
                    //launch request
                    self.dataTask?.resume()
            } else {
                print("noTokenUser")
                completion(false)
            }
        }
    }
    
    func createCard(stripeId: String, card: STPCardParams, completion: @escaping (_ success: Bool) -> Void) {
        
        stripeTool.generateToken(card: card) { (token) in
            if(token != nil) {
                let request = NSMutableURLRequest(url: URL(string: "https://api.stripe.com/v1/customers/\(stripeId)/sources")!)
                
                //token needed
                var params = [String:String]()
                params["source"] = token!.tokenId
                
                var str = ""
                params.forEach({ (key, value) in
                    str = "\(str)\(key)=\(value)&"
                })
                
                //basic auth
                request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
                
                request.httpMethod = "POST"
                
                request.httpBody = str.data(using: String.Encoding.utf8)
                
                self.dataTask = self.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
                    
                    if let error = error {
                        print(error)
                        completion(false)
                    }
                    else if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                        print(json)
                        completion(true)
                    }
                }
                
                self.dataTask?.resume()
            } else {
                print("noTokenCard")
                completion(false)
            }
        }
        
    }
    
    //get user card list
    func getCardsList(completion: @escaping (_ result: [AnyObject]?) -> Void) {
        
        //request to create the user
        let request = NSMutableURLRequest(url: URL(string: "https://api.stripe.com/v1/customers/\(self.customerId!)/sources?object=card")!)
        
        //basic auth
        request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
        
        //POST method, refer to Stripe documentation
        request.httpMethod = "GET"
        
        //create request block
        self.dataTask = self.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
            
            //get returned error
            if let error = error {
                print(error)
                completion(nil)
            }
            else if let httpResponse = response as? HTTPURLResponse {
                //you can also check returned response
                if(httpResponse.statusCode == 200) {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                        let cardsArray = json["data"] as? [AnyObject]
                        completion(cardsArray)
                    }
                }
                else {
                    completion(nil)
                }
            }
        }
        
        //launch request
        self.dataTask?.resume()
        
    }
    
    //get user  list
    func getUsersList(uidEmail: String, completion: @escaping (_ result: [AnyObject]?) -> Void) {
        
        //request to create the user
        let request = NSMutableURLRequest(url: URL(string: "https://api.stripe.com/v1/customers?email=\(uidEmail)")!)
        
        //basic auth
        request.setValue(self.stripeTool.getBasicAuth(), forHTTPHeaderField: "Authorization")
        
        //POST method, refer to Stripe documentation
        request.httpMethod = "GET"
        
        //create request block
        self.dataTask = self.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
            
            //get returned error
            if let error = error {
                print(error)
                completion(nil)
            }
            else if let httpResponse = response as? HTTPURLResponse {
                //you can also check returned response
                if(httpResponse.statusCode == 200) {
                    if let data = data {
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                        let customersArray = json["data"] as? [AnyObject]
                        completion(customersArray)
                    }
                }
                else {
                    completion(nil)
                }
            }
        }
        
        //launch request
        self.dataTask?.resume()
        
    }
}
