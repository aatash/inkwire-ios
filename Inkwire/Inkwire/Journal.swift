//
//  Journal.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//
import Foundation
import Firebase

class Journal {
    
    var title:String?
    var postIds: [String]?
    var description: String?
    var imageUrl: String?
    var observerIds: [String]? {
        didSet {
            if observerIds != nil {
                observerIds = Array(Set(observerIds!))
            }
        }
    }
    var contributorIds: [String]? {
        didSet {
            if contributorIds != nil {
                contributorIds = Array(Set(contributorIds!))
            }
        }
    }
    var journalId: String?
    let dbRef = FIRDatabase.database().reference()
    private var coverPic: UIImage?
    
    /**
     Initialize a journal object using dictionary retrieved from database.
     
     - parameter key: id of the journal
     - parameter journalDict: dictionary containing all information about the journal
 
     */
    init(key: String, journalDict: [String: Any]) {
        journalId = key

        if let journalTitle = journalDict["title"] as? String {
            title = journalTitle
        }
        
        if let posts = journalDict["postIds"] as? [String] {
            postIds = posts
        } else {
            postIds = [String]()
        }
        
        if let URL = journalDict["imageUrl"] as? String {
            imageUrl = URL
        }
        
        if let contributors = journalDict["contributorIds"] as? [String] {
            contributorIds = contributors
        }
        
        if let observers = journalDict["observerIds"] as? [String] {
            observerIds = observers
        } else {
            observerIds = [String]()
        }
        
        if let journalDescription = journalDict["description"] as? String {
            description = journalDescription
        }
    }
    
    /**
     Initialize a new journal that has yet to be saved to the database.
     
     - parameter title: name of the journal
     - parameter description: description of journal
     - parameter coverPic: cover picture for journal
     
     */
    init(title:String, description: String, coverPic: UIImage) {
        self.title = title
        postIds = [String]()
        self.coverPic = coverPic
        contributorIds = [String]()
        contributorIds?.append((FIRAuth.auth()?.currentUser?.uid)!)
        observerIds = [String]()
        self.description = description
    }
    
    /**
     Poll for posts from the database one by one.
     
     - parameter withBlock: closure to call
     - parameter Post: Post to use
     
     */
    func pollForPosts(withBlock: @escaping (Post) -> Void) {
        for postId in (postIds?.reversed())! {
            dbRef.child("Posts/\(postId)").observe(.value, with: { snapshot in
                if snapshot.exists() {
                    if let postDict = snapshot.value as? [String: Any] {
                        let retrievedPost = Post(key: snapshot.key, postDict: postDict)
                        withBlock(retrievedPost)
                    }
                } else {
                    print("Cannot access post")
                }
            })
        }
    }
    
    /**
     Retrieve the cover picture for the journal.
     
     - parameter withBlock: closure to call
     - parameter UIImage: the cover image to use
     
     */
    func getCoverPic(withBlock: @escaping (UIImage) -> Void) {
        InkwireDBUtils.getImage(atPath: imageUrl!, withBlock: { retrievedImage -> Void in
            withBlock(retrievedImage)
        })
    }
    
    /**
     Edit the description of the journal and update in the database.
     
     - parameter newDescription: string of the new description to add
     
     */
    func editDescription(newDescription: String) {
        let ref = FIRDatabase.database().reference()
        ref.child("Journals/").child(journalId!).updateChildValues(["description": description])
    }
    
    /**
     Add new post to journal and save it to the database.
     
     - parameter content: text for the post to be added
     - parameter image: the image for the new post
     - parameter withBlock: closure to call
     - parameter Post: post object to use
     
     */
    func addNewPost(content: String?, image: UIImage?, withBlock: @escaping (Post) -> Void) {
        if content == nil && image == nil {
            print("Could not create post")
            return
        }
        var newPost: Post!
        if content != nil && image == nil {
            newPost = Post(text: content!)
        } else if content == nil && image != nil {
            newPost = Post(image: image!)
        } else {
            newPost = Post(text: content!, image: image!)
        }
        
        newPost.savetoDB(withBlock: { savedPost -> Void in
            self.postIds?.append(savedPost.postId!)
            self.saveToDB(withBlock: nil)
            withBlock(savedPost)
        })
    }
    
    /**
     Save a new journal to the database.
     
     - parameter withBlock: closure to call
     - parameter Journal: journal object to use
     
     */
    func saveToDB(withBlock: ((Journal) -> Void)?) {
        if journalId == nil {
            journalId = dbRef.child("Journals/").childByAutoId().key
        }
        
        if imageUrl == nil {
            InkwireDBUtils.uploadImage(image: coverPic!, withBlock: { urlString -> Void in
                self.imageUrl = urlString
                
                let journalDict: [String: Any] = ["title": self.title!,
                                                  "postIds": self.postIds!,
                                                  "imageUrl": self.imageUrl!,
                                                  "contributorIds": self.contributorIds!,
                                                  "observerIds": self.observerIds!,
                                                  "description": self.description!]
                
                self.dbRef.child("Journals/").updateChildValues([self.journalId!: journalDict], withCompletionBlock: { (error, ref) -> Void in
                    if error != nil {
                        print("Error while saving to db: \(error)")
                    }
                    if withBlock != nil {
                        withBlock!(self)
                    }
                    
                })
            })
        } else {
            let journalDict: [String: Any] = ["title": title!,
                                              "postIds": postIds!,
                                              "imageUrl": imageUrl!,
                                              "contributorIds": contributorIds!,
                                              "observerIds": observerIds!,
                                              "description": description!]
            
            dbRef.child("Journals/").updateChildValues([journalId!: journalDict], withCompletionBlock: { (error, ref) -> Void in
                if error != nil {
                    print("Error while saving to db: \(error)")
                }
                if withBlock != nil {
                    withBlock!(self)
                }
            })
        }
    }
}
