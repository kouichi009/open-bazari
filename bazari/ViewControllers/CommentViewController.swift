//
//  CommentViewController.swift
//  GadgetMarket
//
//  Created by koichi nakanishi on H30/07/17.
//  Copyright © 平成30年 koichi nakanishi. All rights reserved.
//
import UIKit

protocol CommentViewControllerDelegate {
    func reloadDetailVC()
}

class CommentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    
    var post = Post()
    var comments = [Comment]()
    var usermodels = [UserModel]()
    var commentTextViewHeight: CGFloat?
    var usermodel: UserModel?
    
    var delegate: CommentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setUpTextView()
        
        
    }
    
    func setUpTextView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        commentTextView.delegate = self
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.cornerRadius = 5.0
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
            
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchUsers()
    }
    
    
    
    func fetchUsers() {
        
        self.usermodels.removeAll()
        var count = 0
        Api.User.observeAllUsers { (usermodel, userCount) in
            
            count += 1
            
            if let usermodel = usermodel {
                self.usermodels.append(usermodel)
            }
            
            if userCount == count {
                self.loadComments()
            }
        }
    }
    
    func loadComments() {
        var count = 0
        
        self.comments.removeAll()
        self.tableView.reloadData()
        
        Api.Comment.observePostComments(postId: post.id!) { (comment, commentCount) in
            count += 1
            
            if let comment = comment {
                self.comments.insert(comment, at: 0)
            }
            
            if commentCount == count {
                
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    @IBAction func commentsend_TouchUpInside(_ sender: Any) {
        
        guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
        
        if commentTextView.text == "" {
            ProgressHUD.showError("コメントを入力してください。")
            return;
        }
        
        self.sendButton.isEnabled = false
        
        
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let autoKey = Api.Comment.REF_POST_COMMENTS.childByAutoId().key
        Api.Comment.REF_POST_COMMENTS.child(post.id!).child(autoKey!).updateChildValues(["timestamp": timestamp])
        
        var commentTex = commentTextView.text
        commentTex = commentTex?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
    
        if self.post.commentCount == nil {
            self.post.commentCount = 0
        }
        
        Api.Post.REF_POSTS.child(post.id!).updateChildValues(["commentCount": self.comments.count + 1]) { (error, ref) in
            Api.Post.REF_POSTS.child(self.post.id!).child("comments").updateChildValues([currentUid: true])
            self.post.commentCount = (self.post.commentCount! + 1)
            
            self.sendButton.isEnabled = true

        }
        Api.MyCommentPosts.REF_MYCOMMENTING_POSTS.child(currentUid).child(post.id!).setValue(["timestamp": timestamp])
        
        let dict = ["commentText": commentTex, "postId": self.post.id!, "uid": currentUid, "timestamp": timestamp] as? [String: Any]
        Api.Comment.REF_COMMENTS.child(autoKey!).setValue(dict) { (error, ref) in
            
            self.delegate?.reloadDetailVC()
            self.sendButton.isEnabled = true
        }
        if post.uid != currentUid {
            
            if let fcmToken = usermodel?.fcmToken {
                sendPushNotification(token: fcmToken)
            }
            
            Api.Notification.observeExistNotification(uid: post.uid!, postId: post.id!, type: "comment", currentUid: currentUid) { (notificationId) in
                
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                let newNotificationReference = Api.Notification.REF_NOTIFICATION
                let newMyNotificationReference = Api.Notification.REF_MYNOTIFICATION.child(self.post.uid!)
                let newNotificationId = newNotificationReference.childByAutoId().key
                
                self.sendButton.isEnabled = true
                
                if notificationId == nil {
                    
                    newNotificationReference.child(newNotificationId!).setValue(["checked": false, "from": Api.User.CURRENT_USER!.uid, "objectId": self.post.id!, "type": "comment", "timestamp": timestamp, "to": self.post.uid!, "commentId": autoKey, "segmentType": Config.you])
                    newMyNotificationReference.child(newNotificationId!).setValue(["timestamp": timestamp])
                    
                    Api.Notification.REF_EXIST_NOTIFICATION.child(self.post.uid!).child(currentUid).child(self.post.id!).child("comment").setValue([newNotificationId!: true])
                    
                } else {
                    newMyNotificationReference.child(notificationId!).updateChildValues(["timestamp": timestamp])
                }
            }
            
            
            //商品投稿者がコメントしたときだけ、商品にコメントを残した人たちに通知を送る
        } else {
            
            if let withUserpostComments = post.comments {
                for withUserComment in withUserpostComments {
                    let withUserCommentUid = withUserComment.key
                    
                    print("withUserCommentUid \(withUserCommentUid)")
                    print("currentUid \(currentUid)")
                    
                    if withUserCommentUid != currentUid {
                        
                        Api.Notification.observeExistNotification(uid: withUserCommentUid, postId: post.id!, type: "comment", currentUid: currentUid) { (notificationId) in
                            
                            self.sendButton.isEnabled = true
                            
                            print("notifiId ", notificationId)
                            let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                            let newNotificationReference = Api.Notification.REF_NOTIFICATION
                            let newMyNotificationReference = Api.Notification.REF_MYNOTIFICATION.child(withUserCommentUid)
                            let newNotificationId = newNotificationReference.childByAutoId().key
                            
                            if notificationId == nil {
                                
                                newNotificationReference.child(newNotificationId!).setValue(["checked": false, "from": Api.User.CURRENT_USER!.uid, "objectId": self.post.id!, "type": "comment", "timestamp": timestamp, "to": withUserCommentUid, "commentId": autoKey, "segmentType": Config.you])
                                newMyNotificationReference.child(newNotificationId!).setValue(["timestamp": timestamp])
                                
                                Api.Notification.REF_EXIST_NOTIFICATION.child(withUserCommentUid).child(currentUid).child(self.post.id!).child("comment").setValue([newNotificationId!: true])
                            } else {
                                newMyNotificationReference.child(notificationId!).updateChildValues(["timestamp": timestamp])
                            }
                        }
                    }
                }
            }
        }
        
        
        
        cleanText()
        loadComments()
    }
    
    func cleanText() {
        self.commentTextView.text = ""
        textHeightConstraint.constant = commentTextView.contentSize.height
    }
    
    func sendPushNotification(token: String) {
        
        let indexNum = Config.pushNotiTitleCount
        var titleStr: String = post.title!
        
       if titleStr.count > indexNum {
            titleStr = String(titleStr.prefix(indexNum))
            titleStr = titleStr+"..."
        }
        let message = "「\(titleStr)」に新着コメントがあります。"
        
        Api.Notification.sendNotification(token: token, message: message) { (success, error) in
            if success == true {
                print("Notification sent!")
            } else {
                print("Notification sent error!")
            }
        }
    }
    
    
    func showAlert(title: String, message: String, comment: Comment?, post: Post?, isComplain: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let complainAction = UIAlertAction(title: "通報する", style: .default, handler: {(alert: UIAlertAction!) in
            guard let currentUid = Api.User.CURRENT_USER?.uid else {return}
            let autoId = Api.Complain.REF_COMPLAINS.child(currentUid).childByAutoId().key
            Api.Complain.REF_COMPLAINS.child(currentUid).child(autoId!).setValue(["type": "comment", "to": (comment?.uid)!, "commentText": comment?.commentText, "from": currentUid, "id": comment?.id])
            ProgressHUD.showSuccess("通報しました。")
        })
        
        let deleteAction = UIAlertAction(title: "削除する", style: .default, handler: {(alert: UIAlertAction!) in
            self.deleteComment(comment: comment, post: post)
        })
        
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {(alert: UIAlertAction!) in
            
        })
        
        if isComplain {
            alert.addAction(complainAction)
            alert.addAction(cancelAction)
        } else {
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
        }
        
        // iPadでは必須！
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteComment(comment: Comment?, post: Post?) {
        
        if let comment = comment {
            
            let commentCount = (post?.commentCount)! - 1
            print("post?.commentCount ", post?.commentCount)
            print("commentCount ", commentCount)
            Api.Comment.REF_POST_COMMENTS.child(comment.postId!).child(comment.id!).removeValue()
            Api.Post.REF_POSTS.child(comment.postId!).child("comments").child(comment.uid!).removeValue()
            Api.Post.REF_POSTS.child(comment.postId!).updateChildValues(["commentCount": commentCount])
            Api.Comment.REF_COMMENTS.child(comment.id!).removeValue { (error, ref) in
                self.reloadComments()
            }
            
        }
    }
    
    func reloadComments() {
        
        Api.Post.observePost(postId: post.id!) { (post) in
            self.post = post!
            self.loadComments()
            self.delegate?.reloadDetailVC()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToProfileUserSeg" || segue.identifier == "goToProfileUserSeg_iPhoneSE" {
            let profileUserVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserVC.userId = userId
        }
    }
}

extension CommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as? CommentTableViewCell {
            cell.delegate = self
            cell.post = post
            let comment = self.comments[indexPath.item]
            print("com " , comment.commentText)
            for usermod in self.usermodels {
                if self.comments[(indexPath.item)].uid == usermod.id {
                    cell.usermodel = usermod
                }
            }
            cell.comment = comment
            let estimatedSize = cell.commentTextView.sizeThatFits(cell.commentTextView.frame.size)
            commentTextViewHeight = estimatedSize.height - 11
            
            return cell
        }
        
        return UITableViewCell()
    }
}


extension CommentViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        if textView.contentSize.height > textHeightConstraint.constant && textHeightConstraint.constant < 130 {
            //   let difference = textView.contentSize.height - textHeightConstraint.constant
            textHeightConstraint.constant = textView.contentSize.height
        }
            
        else if textView.contentSize.height < textHeightConstraint.constant {
            //   let difference = textHeightConstraint.constant - textView.contentSize.height
            textHeightConstraint.constant = textView.contentSize.height
        }
        
        textView.layoutIfNeeded()
    }
    
    
}

extension CommentViewController: CommentTableViewCellDelegate {
    
    func goToRegisterVC() {
        self.performSegue(withIdentifier: "goToRegisterUser_Seg", sender: nil)
        
    }
    
    func goToProfileUser(userId: String) {
        
        if Config.isUnderIphoneSE {
            self.performSegue(withIdentifier: "goToProfileUserSeg_iPhoneSE", sender: userId)
        } else {
            self.performSegue(withIdentifier: "goToProfileUserSeg", sender: userId)
        }
        
    }
    
    func goToUIAlertController(post: Post?, currentUid: String, comment: Comment?) {
        
        // create menu controller
        let menu = UIAlertController(title: "メニュー", message: nil, preferredStyle: .actionSheet)
        
        
        
        // DELET ACTION
        let delete = UIAlertAction(title: "削除する", style: .default) { (UIAlertAction) -> Void in
            
            self.showAlert(title: "削除していいですか？", message: "", comment: comment, post: post, isComplain: false)
        }
        
        
        // COMPLAIN ACTION
        let complain = UIAlertAction(title: "通報する", style: .default) { (UIAlertAction) -> Void in
            self.showAlert(title: "本当に通報しますか？", message: "", comment: comment, post: post, isComplain: true)
        }
        
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        // if post belongs to user, he can delete post, else he can't
        
        
        if post?.uid == currentUid {
            if comment?.uid == currentUid {
                menu.addAction(delete)
                menu.addAction(cancel)
            } else {
                menu.addAction(delete)
                menu.addAction(complain)
                menu.addAction(cancel)
            }
        } else {
            if comment?.uid == currentUid {
                menu.addAction(delete)
                menu.addAction(cancel)
            } else {
                menu.addAction(complain)
                menu.addAction(cancel)
            }
        }
        
        // iPadでは必須！
        menu.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        menu.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
   
    
    
}
