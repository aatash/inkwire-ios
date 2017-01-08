//
//  PostDetailViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD


class PostDetailViewController: UIViewController, UINavigationControllerDelegate {
    
    var post: Post?
    var comments = [Comment]()
    var collectionView: UICollectionView!
    var numComments = 0
    var newCommentBar: UIView!
    var postButton: UIButton!
    var newCommentTextField: UITextField!
    var hud = JGProgressHUD(style: .light)
    var journal: Journal?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupNewCommentBar()
        
        
        
        post?.pollForComments(withBlock: { retrievedComment -> Void in
            var indexPaths = [IndexPath]()
            if self.comments.index(where: {$0.commentId == retrievedComment.commentId}) != nil || retrievedComment.date == nil{
                return
            }
            self.comments.append(retrievedComment)
            self.comments.sort(by: { (commentOne, commentTwo) -> Bool in
                return commentOne.date! < commentTwo.date!
            })
            let index = self.comments.index(where: {$0.commentId == retrievedComment.commentId})
            indexPaths.append(IndexPath(item: index!, section: 1))
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({ Void in
                    self.collectionView.insertItems(at: indexPaths)
                    self.numComments += indexPaths.count
                    }, completion: nil)
            }
        })
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        beganKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        endKeyboardNotifications()
    }
    
    func setupNewCommentBar() {
        let navBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        newCommentBar = UIView(frame: CGRect(x: 0, y: view.frame.height - 60 - navBarHeight! - statusBarHeight, width: view.frame.width, height: 60))
        newCommentBar.backgroundColor = UIColor.white
        newCommentBar.layer.shadowColor = UIColor(hex: "#DDD4D4").cgColor
        newCommentBar.layer.shadowOffset = CGSize(width: 2, height: -2)
        newCommentBar.layer.shadowOpacity = 0.9
        newCommentBar.layer.shadowRadius = 2 
        view.addSubview(newCommentBar)
        
        newCommentTextField = UITextField(frame: CGRect(x: 20, y: 15, width: newCommentBar.frame.width - 20 - 50, height: 30))
        newCommentTextField.borderStyle = .none
        newCommentTextField.placeholder = "Write a comment..."
        newCommentTextField.font = UIFont(name: "SFUIText-Regular", size: 14)
        newCommentTextField.delegate = self
        newCommentTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        newCommentBar.addSubview(newCommentTextField)
        
        postButton = UIButton(frame: CGRect(x: newCommentBar.frame.maxX - 50, y: 15, width: 45, height: 30))
        postButton.setTitle("Post", for: .normal)
        postButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 14)
        postButton.setTitleColor(Constants.likeColor, for: .normal)
        postButton.setTitleColor(UIColor.gray, for: .disabled)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        postButton.isEnabled = false
        newCommentBar.addSubview(postButton)
    }

    
    
    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = Constants.appColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrow")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.day, .month], from: (post?.date!)!)
        let month = Constants.months[dateComponents.month! - 1]
        let day = dateComponents.day!
        navigationItem.title = "\(day) \(month)"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        var items = [UIBarButtonItem]()
        let flagButton = UIBarButtonItem(image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(flagButtonTapped))
        items.append(flagButton)
        if post?.posterId == FIRAuth.auth()?.currentUser?.uid {
            let deleteButton = UIBarButtonItem(image: UIImage(named: "trash2"), style: .plain, target: self, action: #selector(deleteButtonTapped))
            items.append(deleteButton)
        }
        navigationItem.rightBarButtonItems = items
        
        
    }
    
    
    func delete() {
        hud?.textLabel.text = "Deleting..."
        hud?.show(in: view)
        if let i = journal?.postIds?.index(of: post!.postId!) {
            journal?.postIds?.remove(at: i)
            journal?.saveToDB(withBlock: { savedJournal -> Void in
                DispatchQueue.main.async {
                    self.hud?.dismiss()
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        
        
        
    }
    
    func deleteButtonTapped() {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        let nextAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { action -> Void in
            self.delete()
        }
        alert.addAction(cancelAction)
        alert.addAction(nextAction)
        present(alert, animated: true, completion: nil)
    }

    
    func flagButtonTapped() {
        let alert = UIAlertController(title: "Flag Post", message: "Flag this post if you found the content inappropriate.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        let doneAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
            FIRDatabase.database().reference().child("Posts/\(self.post?.postId!)/flagged").setValue(1)
        }
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        present(alert, animated: true, completion: nil)
    }

    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 60), collectionViewLayout: layout)
        collectionView.register(ImageTextDetailCollectionViewCell.self, forCellWithReuseIdentifier: "imageTextCell")
        collectionView.register(TextDetailCollectionViewCell.self, forCellWithReuseIdentifier: "textCell")
        collectionView.register(ImageDetailCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: "commentCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        
        view.addSubview(collectionView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditting))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    func endEditting() {
        if newCommentTextField.isFirstResponder {
            newCommentTextField.endEditing(true)
        }
    }
    
    func postButtonTapped() {
        let postText = newCommentTextField.text
        newCommentTextField.text = ""
        postButton.isEnabled = false
        post?.addNewComment(text: postText!, withBlock: { savedComment -> Void in
            var indexPaths = [IndexPath]()
            if self.comments.index(where: {$0.commentId == savedComment.commentId}) != nil || savedComment.date == nil{
                return
            }
            self.comments.append(savedComment)
            self.comments.sort(by: { (commentOne, commentTwo) -> Bool in
                return commentOne.date! < commentTwo.date!
            })
            let index = self.comments.index(where: {$0.commentId == savedComment.commentId})
            indexPaths.append(IndexPath(item: index!, section: 1))
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({ Void in
                    self.collectionView.insertItems(at: indexPaths)
                    self.numComments += indexPaths.count
                    }, completion: { Void in
                    self.newCommentTextField.text = ""
                    self.newCommentTextField.endEditing(true)
                })
            }
        })
    }

}

extension PostDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return numComments
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            var cell: PostDetailCollectionViewCell!
            let cellSizeAttr = CellSizeCalculator.sizeForDetailCell(withPost: post!)
            if post?.imageUrl == nil && post?.content != nil {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextDetailCollectionViewCell
            } else if post?.imageUrl != nil && post?.content != nil {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTextCell", for: indexPath) as! ImageTextDetailCollectionViewCell
                
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageDetailCollectionViewCell
            }
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            cell.awakeFromNib()
            
            cell.setupCell(withAttr: cellSizeAttr)
        
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as! CommentCollectionViewCell
            
            
            let comment = comments[indexPath.item]
            let cellSizeAttr = CellSizeCalculator.sizeForCommentCell(withComment: comment)
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            cell.awakeFromNib()
            
            cell.setupCell(withAttr: cellSizeAttr)
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let currUserId = FIRAuth.auth()?.currentUser?.uid
            var genericPostCell: PostDetailCollectionViewCell!
            if post?.imageUrl == nil && post?.content != nil {
                let postCell = cell as! TextDetailCollectionViewCell
                postCell.contentLabel.text = post?.content!
                genericPostCell = postCell
            } else if post?.imageUrl != nil && post?.content != nil {
                let postCell = cell as! ImageTextDetailCollectionViewCell
                postCell.contentLabel.text = post?.content!
                post?.getImage(withBlock: { retrievedImage -> Void in
                    postCell.imageView.image = retrievedImage
                })
                genericPostCell = postCell
            } else {
                let postCell = cell as! ImageDetailCollectionViewCell
                post?.getImage(withBlock: { retrievedImage -> Void in
                    postCell.imageView.image = retrievedImage
                })
                genericPostCell = postCell
            }
            genericPostCell.post = post
            post?.getPoster(withBlock: { retrievedUser -> Void in
                genericPostCell.usernameLabel.text = retrievedUser.name!
                retrievedUser.getProfPic(withBlock: { retrievedImage -> Void in
                    genericPostCell.profPicImageView.image = retrievedImage
                })
            })
            if (post?.likedUserIds?.contains(currUserId!))! {
                genericPostCell.setLiked()
            }
            genericPostCell.likesLabel.text = "\(post!.likedUserIds!.count)"
            genericPostCell.commentsLabel.text = "\(post!.commentIds!.count)"
        } else {
            let cell = cell as! CommentCollectionViewCell
            let comment = comments[indexPath.item]
            cell.contentLabel.text = comment.content!
            comment.getCommenter(withBlock: { retrievedUser -> Void in
                cell.usernameLabel.text = retrievedUser.name
                retrievedUser.getProfPic(withBlock: { retrievedImage -> Void in
                    cell.profPicImageView.image = retrievedImage
                })
            })
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            let cellSizeAttr = CellSizeCalculator.sizeForDetailCell(withPost: post!)
            return CGSize(width: view.frame.width, height: cellSizeAttr.cellContainerHeight! + 60)
        }
        
        let comment = comments[indexPath.item]
        let cellSizeAttr = CellSizeCalculator.sizeForCommentCell(withComment: comment)
        
        
        return CGSize(width: view.frame.width, height: cellSizeAttr.cellHeight!)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newCommentTextField.endEditing(true)
    }
    
}

extension PostDetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func beganKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func endKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                newCommentBar.frame.origin.y = view.frame.height - keyboardSize.height - 60
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        
        newCommentBar.frame.origin.y = view.frame.height - 60
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        newCommentTextField.endEditing(true)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "Write a comment..." || textField.text == nil || textField.text == "" {
            postButton.isEnabled = false
        } else {
            postButton.isEnabled = true
        }
    }


}
