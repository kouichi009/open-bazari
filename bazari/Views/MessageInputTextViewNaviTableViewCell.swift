//
//  MessageInputTextViewNaviTableViewCell.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/26.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

protocol MessageInputTextViewNaviTableViewCellDelegate {
    func pressSendMessage()
}

class MessageInputTextViewNaviTableViewCell: UITableViewCell {

    @IBOutlet weak var inputTextView: KMPlaceholderTextView!
    
    var delegate: MessageInputTextViewNaviTableViewCellDelegate?
    var usermodel: UserModel?
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        inputTextView.placeholder = "ここにメッセージ内容を記入してください。"
    }
    
    @IBAction func messageButton_TouchUpInside(_ sender: Any) {
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
        
        var text = self.inputTextView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if text == "" {
            ProgressHUD.showError("メッセージ内容を記入してください。")
            return;
        }
        
        //change date here
        let key = Api.Message.REF_MESSAGE.child((post?.id)!).childByAutoId().key
        let timestamp = Int(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "Asia/Tokyo") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let dateString = dateFormatter.string(from: date)
        Api.Chat.REF_CHATS.child((post?.id)!).child(key!).setValue(["date": dateString, "messageText": text, "timestamp": timestamp, "uid": currentUid]) { (error, ref) in
        }
        
        let notiKey = Api.Notification.REF_NOTIFICATION.childByAutoId().key
        Api.Notification.REF_MYNOTIFICATION.child((usermodel?.id)!).child(notiKey!).setValue(["timestamp": timestamp])
        Api.Notification.REF_NOTIFICATION.child(notiKey!).setValue(["checked": false, "from": currentUid, "objectId": (post?.id)!, "segmentType": "transaction", "timestamp": timestamp, "to": (usermodel?.id)!, "type": Config.naviMessage])
        
        delegate?.pressSendMessage()
        
        clean()
    }
    
    func clean() {
        inputTextView.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
