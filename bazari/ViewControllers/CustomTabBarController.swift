//
//  CustomTabBarController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/24.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import ESTabBarController_swift
import UIKit

class CustomTabBarController: ESTabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard1: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let navigationController1 = storyBoard1.instantiateViewController(withIdentifier: "NavigationHome")  as! UINavigationController
        let v1 = navigationController1.topViewController as! Home1ViewController
        
//        let storyBoard2: UIStoryboard = UIStoryboard(name: "Discover", bundle: nil)
//        let navigationController2 = storyBoard2.instantiateViewController(withIdentifier: "NavigationDiscover")  as! UINavigationController
//        let v2 = navigationController2.topViewController as! DiscoverViewController
        
        let storyBoard3: UIStoryboard = UIStoryboard(name: "Post", bundle: nil)
        let navigationController3 = storyBoard3.instantiateViewController(withIdentifier: "NavigationPost")  as! UINavigationController
        let v3 = navigationController3.topViewController as! NewPostViewController
        
        let storyBoard4: UIStoryboard = UIStoryboard(name: "Notification", bundle: nil)
        let navigationController4 = storyBoard4.instantiateViewController(withIdentifier: "NavigationNotification")  as! UINavigationController
        let v4 = navigationController4.topViewController as! NotificationViewController
        
        let storyBoard5: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let navigationController5 = storyBoard5.instantiateViewController(withIdentifier: "NavigationProfile")  as! UINavigationController
        let v5 = navigationController5.topViewController as! ProfileMenuViewController
        
        v1.tabBarItem = ESTabBarItem.init(TabBarContentView(), title: "ホーム", image: UIImage(named: "Home"), selectedImage: UIImage(named: "Home_Selected"))
//        v2.tabBarItem = ESTabBarItem.init(TabBarContentView(), title: "さがす", image: UIImage(named: "Search"), selectedImage: UIImage(named: "Search_Selected"))
        v3.tabBarItem = ESTabBarItem.init(TabBarContentView(), title: "出品", image: UIImage(named: "addPhoto"), selectedImage: UIImage(named: "addPhoto"))
        v4.tabBarItem = ESTabBarItem.init(TabBarContentView(), title: "お知らせ", image: UIImage(named: "notification"), selectedImage: UIImage(named: "notification"))
        v5.tabBarItem = ESTabBarItem.init(TabBarContentView(), title: "マイページ", image: UIImage(named: "Profile"), selectedImage: UIImage(named: "Profile_Selected"))
        
        self.viewControllers = [navigationController1,navigationController3,navigationController4,navigationController5]
        
        if let currentUid = Api.User.CURRENT_USER?.uid {

            Api.Notification.observeNotifications(uid: currentUid) { (notification, notiCount) in

                if notification.checked == false {
                    if let items = self.tabBar.items {
                        items[2].badgeValue = ""
                    }
                    return;
                }
            }

            Api.MyPurchasePosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in

                if let post = post {
                    if post.purchaserShouldDo == Config.catchProduct {
                        if let items = self.tabBar.items {
                            items[3].badgeValue = ""
                        }
                    }
                }
            }

            Api.MySellPosts.observeMyAllPosts(userId: currentUid) { (post, postCount) in

                if let post = post {
                    if post.sellerShouldDo == Config.ship || post.sellerShouldDo == Config.valueBuyer {
                        if let items = self.tabBar.items {
                            items[3].badgeValue = ""
                        }
                    }
                }
            }

        }
        
    }
}
