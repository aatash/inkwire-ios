//
//  Post.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    var date: Date?
    var posterId: String?
    var commentIds: [String]?
    var content: String?
    var imageUrl: String?
    var postId: String?
    var likedUserIds: [String]?
    private var postImage: UIImage?
    let dbRef = FIRDatabase.database().reference()
    
    /**
     Initialize a post object using dictionary retrieved from database.
     
     - parameter key: id of the journal
     - parameter postDict: dictionary containing all information about the user
     
     */
    init(key: String, postDict: [String: Any]) {
        postId = key
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        if let createdAtString = postDict["date"] as? String {
            date = dateFormatter.date(from: createdAtString)
        }
        if let posterId = postDict["posterId"] as? String {
            self.posterId = posterId
        }
        if let commentIds = postDict["commentIds"] as? [String] {
            self.commentIds = commentIds
        } else {
            commentIds = [String]()
        }
        if let imageUrl = postDict["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        if let postId = postDict["postId"] as? String {
            self.postId = postId
        }
        if let postImage = postDict["postImage"] as? UIImage {
            self.postImage = postImage
        }
        if let likes = postDict["likedUserIds"] as? [String] {
            likedUserIds = likes
        } else {
            likedUserIds = [String]()
        }
        if let description = postDict["content"] as? String {
            content = description
        }
    }
    
    /**
     Initialize a post object using text only.
     
     - parameter text: text for the post
     
     */
    init(text: String) {
        date = Date()
        posterId = FIRAuth.auth()?.currentUser?.uid
        commentIds = [String]()
        content = text
        likedUserIds = [String]()
    }
    
    /**
     Initialize a post object using an image only.
     
     - parameter image: image for the post
     
     */
    init(image: UIImage) {
        date = Date()
        posterId = FIRAuth.auth()?.currentUser?.uid
        commentIds = [String]()
        postImage = image
        likedUserIds = [String]()
    }
    
    /**
     Initialize a post object using text and an image.
     
     - parameter text: text for the post
     - parameter image: image for the post
     
     */
    init(text: String, image: UIImage) {
        date = Date()
        posterId = FIRAuth.auth()?.currentUser?.uid
        commentIds = [String]()
        content = text
        postImage = image
        likedUserIds = [String]()
    }
    
    /**
     Poll for comments from the database one by one.
     
     - important: withBlock is called each time a comment is retrieved
     - parameter withBlock: closure to call
     - parameter Post: Post to use
     
     */
    func pollForComments(withBlock: @escaping (Comment) -> Void) {
        for commentID in commentIds! {
            dbRef.child("Comments/\(commentID)").observe(.value, with: { snapshot in
                if snapshot.exists() {
                    if let commentDict = snapshot.value as? [String: Any] {
                        let retrievedComment = Comment(key: snapshot.key, commentDict: commentDict)
                        withBlock(retrievedComment)
                    }
                } else {
                    print("Cannot access Comment")
                }
            })
        }
    }
    
    /**
     Get the user who posted the post.
     
     - parameter withBlock: closure to call
     - parameter User: user who has posted to use in closure
     
     */
    func getPoster(withBlock: @escaping (User) -> Void) {
        InkwireDBUtils.getUser(withId: posterId!, withBlock: { retrievedUser -> Void in
            withBlock(retrievedUser)
        })
    }
    
    /**
     Initialize a new comment object and save it to the database.
     
     - parameter text: text for the comment object
     - parameter withBlock: closure to call
     - parameter Comment: comment to use
     
     */
    func addNewComment(text: String, withBlock: @escaping (Comment) -> Void) {
        let newComment = Comment(text: text)
        newComment.saveToDB(withBlock: { savedComment -> Void in
            self.commentIds?.append(savedComment.commentId!)
            self.savetoDB(withBlock: nil)
            withBlock(savedComment)
        })
        
        let notificationId = dbRef.child("notifications/").childByAutoId().key
        
        let notificationMessage = "Someone commented on your post!"
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        let notificationDict: [String: Any] = ["attempts": 0,
                                               "key": notificationId,
                                               "message": notificationMessage,
                                               "read": false,
                                               "sent": false,
                                               "senderUID": currUserId!,
                                               "recipientUID": posterId!,
                                               "time": String(describing: Date())]
        
        dbRef.child("notifications/").updateChildValues([notificationId: notificationDict])
    }
    
    /**
     Get the image of the post.
     
     - parameter withBlock: closure to call
     - parameter UIImage: image to use
     
     */
    func getImage(withBlock: @escaping (UIImage) -> Void) {
        if imageUrl == nil {
            return
        }
        if postImage != nil {
            withBlock(postImage!)
            return
        }
        InkwireDBUtils.getImage(atPath: imageUrl!, withBlock: { retrievedImage -> Void in
            withBlock(retrievedImage)
        })
    }
     
    /**
     Save a new post to the database.
     
     - parameter withBlock: closure to call
     - parameter Post: post object to use
     
     */
    func savetoDB(withBlock: ((Post) -> Void)?) {
        if postId == nil {
            postId = dbRef.childByAutoId().key
        }
        var postDict: [String: Any]!
        if imageUrl == nil && postImage == nil {
            postDict = ["date": String(describing: date!),
                        "posterId": posterId!,
                        "commentIds": commentIds!,
                        "content": content!,
                        "likedUserIds": likedUserIds!]
            
            dbRef.child("Posts/").updateChildValues(([postId!: postDict]) , withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error while saving to db: \(error)")
                }
                if withBlock != nil {
                    withBlock!(self)
                }
                
            })
        } else if imageUrl != nil {
            postDict = ["date": String(describing: date!),
                        "posterId": posterId!,
                        "commentIds": commentIds!,
                        "content": content!,
                        "imageUrl": imageUrl!,
                        "likedUserIds": likedUserIds!]
            
            dbRef.child("Posts/").updateChildValues(([postId!: postDict]) , withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error while saving to db: \(error)")
                }
                if withBlock != nil {
                    withBlock!(self)
                }
                
            })
        } else if postImage != nil && imageUrl == nil {
            uploadImage(withBlock: { url -> Void in
                self.imageUrl = url
                if self.content != nil {
                    postDict = ["date": String(describing: self.date!),
                                "posterId": self.posterId!,
                                "commentIds": self.commentIds!,
                                "content": self.content!,
                                "imageUrl": self.imageUrl!,
                                "likedUserIds": self.likedUserIds!]
                } else {
                    postDict = ["date": String(describing: self.date!),
                                "posterId": self.posterId!,
                                "commentIds": self.commentIds!,
                                "imageUrl": self.imageUrl!,
                                "likedUserIds": self.likedUserIds!]
                }
                
                self.dbRef.child("Posts/").updateChildValues(([self.postId!: postDict]) , withCompletionBlock: { (error, ref) -> Void in
                    if error != nil {
                        print("Error while saving to db: \(error)")
                    } else {
                        print("saved post to db successfully")
                    }
                    if withBlock != nil {
                        withBlock!(self)
                    }
                    
                })
            })
        }
        
    }
    
    /**
     Upload the image to the database.
     
     - parameter withBlock: closure to call
     - parameter String: the image url to use
     
     */
    private func uploadImage(withBlock: @escaping (String) -> Void) {
        let imageRef = FIRStorage.storage().reference().child("images/\(postId!).jpg")
        imageRef.put(UIImageJPEGRepresentation(postImage!, 0.9)!, metadata: nil) { metadata, error in
            if (error != nil) {
                print("Error while uploading image: \(error)")
            } else {
                print("no error while uploading")
                let downloadURL = metadata?.downloadURL()
                withBlock((downloadURL?.absoluteString)!)
            }
        }
    }
    
    func like() {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        if (likedUserIds?.contains(currUserId!))! {
            return
        }
        likedUserIds?.append(currUserId!)
        savetoDB(withBlock: nil)
        
        let notificationId = dbRef.child("notifications/").childByAutoId().key
        
        let notificationMessage = "Someone liked your post!"
        
        let notificationDict: [String: Any] = ["attempts": 0,
                                               "key": notificationId,
                                               "message": notificationMessage,
                                               "read": false,
                                               "sent": false,
                                               "senderUID": currUserId!,
                                               "recipientUID": posterId!,
                                               "time": String(describing: Date())]
        
        dbRef.child("notifications/").updateChildValues([notificationId: notificationDict])
    }
    
    func unlike() {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        if (likedUserIds?.contains(currUserId!))! {
            let index = likedUserIds?.index(where: {$0 == currUserId})
            likedUserIds?.remove(at: index!)
            savetoDB(withBlock: nil)
        }
    }

}
