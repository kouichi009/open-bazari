//
//  NotificationTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/08/01.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit

protocol NotificationTableViewCellDelegate {
    func goToDetailVC(post: Post, usermodel: UserModel)
    func goToProfileVC(usermodel: UserModel)
    func goToCommentVC(post: Post, usermodel: UserModel)
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var delegate: NotificationTableViewCellDelegate?
    
    var touchFlg = false
    var timeText = ""
    
    var post: Post?
    
    var notification: Notification? {
        didSet {
            updateView()
        }
    }
    
    var usermodel: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    
    func updateView() {
        
        print("notification.type \(notification?.type)")
        print("notification \(notification)")
        print(usermodel?.username)
        print(usermodel?.id)
        print(post?.title)
        print(post?.id)
        
        if let _ = post?.id {
            
            switch notification!.type! {
                
                
            case "like":
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((usermodel?.username)!)さんが「\((post?.title)!)」にいいね!しました"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんがいいね!しました"
                }
                
                
            case "comment":
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((usermodel?.username)!)さんが「\((post?.title)!)」にコメントしました"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんがにいいね!しました"
                }
                
                
            case "priceDown":
                descriptionLabel.text = "「\((post?.title)!)」が\((Functions.formatPrice(price: (post?.price)!)))円に値下げされました。"
                
            case Config.naviPurchase:
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((self.usermodel?.username)!)さんから、「\((post?.title)!)」の商品代金が支払われました。商品を発送してください。"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんが商品代金が支払われました。商品を発送してください。"
                }
            case Config.naviShip:
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((self.usermodel?.username)!)さんから、「\((post?.title)!)」が発送されました。商品が到着したら受取通知を行なってください。"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんから、商品が発送されました。商品が到着したら受取通知を行なってください。"
                }
                
                
            case Config.naviEvaluatePurchaser:
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((self.usermodel?.username)!)さんから\((post?.title)!)の受取通知がありました。購入者の評価を行い、取引を完了させてください。"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんから、商品の受取通知がありました。購入者の評価を行い、取引を完了させてください。"
                }
                
            case Config.naviEvaluateSeller:
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((self.usermodel?.username)!)さんから取引の評価がつきました。これで取引は完了です。"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんから、取引の評価がつきました。これで取引は完了です。"
                }
                
            case Config.naviMessage:
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((self.usermodel?.username)!)さんから「\((post?.title)!)」の取引メッセージが届きました。"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんから、取引メッセージが届きました。"
                }
                
            default:
                print("t")
            }
            
           
        } else {
            
            if notification?.from == "admin" {
                descriptionLabel.text = (notification?.objectId)!
                let photoUrlString = Config.adminImage
                let photoUrl = URL(string: photoUrlString)
                profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
            } else if "follow" == notification?.type {
                
                if let _ = usermodel {
                    descriptionLabel.text = "\((usermodel?.username)!)さんがあなたをフォローしました。"
                } else {
                    descriptionLabel.text = "(削除済みユーザー)さんがあなたをフォローしました。"
                }
            }
        }
        
        if let timestamp = notification?.timestamp {
            print(timestamp)
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            //            var timeText = ""
            if diff.second! <= 0 {
                timeText = "たった今"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!)秒前"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!)分前"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!)時間前"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!)日前"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)週間前"
            }
            
            timeLabel.text = timeText
        }
    }
    
    func setupUserInfo() {
        if let photoUrlString = usermodel?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg"))
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        timeLabel.text = ""
        descriptionLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
