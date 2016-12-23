//
//  Comment.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//
import Foundation
import Firebase

class Comment {
    
    var date: Date?
    var content: String?
    var commenterId: String?
    var commentId: String?
    let dbRef = FIRDatabase.database().reference()
    
    /**
     Initialize a comment object using dictionary retrieved from database.
     
     - parameter key: id of the journal
     - parameter commentDict: dictionary containing all information about the comment
     
     */
    init(key: String, commentDict: [String: Any]) {
        commentId = key
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        if let createdAtString = commentDict["date"] as? String {
            date = dateFormatter.date(from: createdAtString)
        }
        if let text = commentDict["text"] as? String {
            content = text
        }
        
        if let commenter = commentDict["userID"] as? String {
            commenterId = commenter
        }
    }
    
    /**
     Initialize a comment object using text for the comment.
     
     - parameter text: text for the comment
     
     */
    init(text: String) {
        date = Date()
        content = text
        commenterId = FIRAuth.auth()?.currentUser?.uid
    }
    
    /**
     Get the user that posted the comment.
     
     - parameter withBlock: closure to call
     - parameter User: user who posted to the comment to use
     
     */
    func getCommenter(withBlock: @escaping (User) -> Void) {
        InkwireDBUtils.getUser(withId: commenterId!, withBlock: { retrievedUser -> Void in
            withBlock(retrievedUser)
        })
    }
    
    /**
     Save a new comment to the database.
     
     - parameter withBlock: closure to call
     - parameter Comment: comment object to use
     
     */
    func saveToDB(withBlock: @escaping (Comment) -> Void) {
        if commentId == nil {
            commentId = dbRef.child("Comments/").childByAutoId().key
        }
        let commentDict = ["date": String(describing: date!),
                           "text": content!,
                           "userID": commenterId!] as [String : Any]
        dbRef.child("Comments/").updateChildValues([commentId!: commentDict], withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("Error while saving to db: \(error)")
            }
            withBlock(self)
        })
    }
}
