//
//  User.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var name: String?
    var email: String?
    var profPicUrl: String?
    var receivedInviteIds: [String]? {
        didSet {
            if receivedInviteIds != nil {
                receivedInviteIds = Array(Set(receivedInviteIds!))
            }
            
        }
    }
    var journalIds: [String]? {
        didSet {
            if journalIds != nil {
                journalIds = Array(Set(journalIds!))
            }
        }
    }
    var userId: String?
    
    /**
     Initialize a user object using dictionary retrieved from database.
     
     - parameter key: id of the user
     - parameter userDict: dictionary containing all information about the user
     
     */
    convenience init(key: String, userDict: [String: Any]) {
        self.init()
        userId = key
        if let username = userDict["fullName"] as? String {
            name = username
        } else {
            name = ""
        }
        if let userEmail = userDict["email"] as? String {
            self.email = userEmail
        }
        if let userUrl = userDict["profPicUrl"] as? String {
            self.profPicUrl = userUrl
        } else {
            profPicUrl = ""
        }
        if let userReceivedInviteIds = userDict["receivedInviteIds"] as? [String] {
            self.receivedInviteIds = userReceivedInviteIds
        } else {
            receivedInviteIds = [String]()
        }
        if let userJournalIds = userDict["journalIds"] as? [String] {
            self.journalIds = userJournalIds
        } else {
            journalIds = [String]()
        }
    }
    
    /**
     Retrieve the profile picture for the user from the database.
     
     - parameter withBlock: closure to call
     - parameter UIImage: the cover image to use
     
     */
    func getProfPic(withBlock: @escaping (UIImage) -> Void) {
        InkwireDBUtils.getImage(atPath: profPicUrl!, withBlock: { retrievedImage -> Void in
            withBlock(retrievedImage)
        })
    }
    
    /**
     Save a new user to the database.
     
     - parameter withBlock: closure to call
     - parameter User: user object to use
     
     */
    func saveToDB(withBlock: @escaping (User) -> Void) {
        let userDict: [String: Any] = ["fullName": name!,
                        "email": email!,
                        "profPicUrl": profPicUrl!,
                        "receivedInviteIds": receivedInviteIds!,
                        "journalIds": journalIds!]
        FIRDatabase.database().reference().child("Users/").updateChildValues([userId!: userDict], withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("Error while saving user data: \(error)")
            }
            withBlock(self)
        })
    }
}
