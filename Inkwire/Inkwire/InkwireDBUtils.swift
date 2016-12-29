//
//  InkwireDBUtils.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/12/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import Firebase
import Haneke
import Spring
class InkwireDBUtils {
    
    
    /**
     Gets the needed image from the database based on the given user path.
     
     - parameter atPath: path in database for the image that needs to be retrieved
     - parameter withBlock: closure to be called
     - parameter UIImage: image to be used
     
     */
    static func getImage(atPath: String, withBlock: @escaping (UIImage) -> Void) {
        let cache = Shared.imageCache
        //TODO: fix loading twice thing
        if let imageUrl = atPath.toURL() {
            cache.fetch(URL: imageUrl as URL).onSuccess({ (image) in
                withBlock(image)
            })
        }
    }
    
    /**
     Gets the needed user from the database based on the given userID.
     
     - parameter withID: userID in database for the user that needs to be retrieved
     - parameter withBlock: closure to be called
     - parameter User: user to be used
     
     */
    static func getUser(withId: String, withBlock: @escaping (User) -> Void) {
        FIRDatabase.database().reference().child("Users/\(withId)").observe(.value, with: { snapshot in
            if snapshot.exists() {
                if let userDict = snapshot.value as? [String: Any] {
                    let retrievedUser = User(key: snapshot.key, userDict: userDict)
                    withBlock(retrievedUser)
                }
            } else {
                print ("Cannot get user")
            }
        })
    }
    
    static func getUserOnce(withId: String, withBlock: @escaping (User) -> Void) {
        FIRDatabase.database().reference().child("Users/\(withId)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let userDict = snapshot.value as? [String: Any] {
                    let retrievedUser = User(key: snapshot.key, userDict: userDict)
                    withBlock(retrievedUser)
                }
            } else {
                print ("Cannot get user")
            }
        })
    }
    
    /**
     Uploads given image to database and generates imageURL to be used.
     
     - parameter image: image to be stored in database
     - parameter withBlock: closure to be called
     - parameter String: image's URL to be used
     
     */
    static func uploadImage(image: UIImage, withBlock: @escaping (String) -> Void) {
        let storageRef = FIRStorage.storage().reference()
        let data = UIImageJPEGRepresentation(image, 0.9)
        let timeStamp = String(describing: Date())
        let imageRef = storageRef.child("images/\(timeStamp).jpg")
        imageRef.put(data!, metadata: nil) { metadata, error in
            if (error != nil) {
                print("an error occurred while uploading the image: \(error)")
            } else {
                let downloadURL = metadata!.downloadURL()
                withBlock((downloadURL?.absoluteString)!)
            }
        }
    }
    
    /**
     Gets an array of users from the database based on a given String prefix.
     
     - parameter prefix: String prefix used to query array of users
     - parameter withBlock: closure to be called
     - parameter [User]: array of retrieved users based on the query
     
     */
    static func getUsersByName(prefix: String, withBlock: @escaping ([User]) -> Void) {
        var query = FIRDatabase.database().reference().child("Users/").queryOrdered(byChild: "fullName")
        if prefix != "" {
            query = query.queryStarting(atValue: prefix, childKey: "fullName").queryEnding(atValue: "\(prefix)\u{f8ff}")
        }
        
        query.observe(.value, with: { snapshot -> Void in
            var retrievedUsers = [User]()
            if snapshot.exists() {
                if let usersDict = snapshot.value as? [String: Any] {
                    for key in usersDict.keys {
                        if let userDict = usersDict[key] as? [String: Any] {
                            let retrievedUser = User(key: key, userDict: userDict)
                            retrievedUsers.append(retrievedUser)
                        }
                    }
                    
                }
            }
            withBlock(retrievedUsers)
        })
    }
    
    /**
     Checks how many pending invites are present in the database for the current user.
     
     - parameter withBlock: closure to be called
     - parameter Int: number of invites retrieved
     
     */
    static func checkNumPendingInvites(withBlock: @escaping (Int) -> Void) {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        getUser(withId: currUserId!, withBlock: { currUser -> Void in
            withBlock((currUser.receivedInviteIds?.count)!)
        })
    }
    
    /**
     Gets the needed journal from the database based on the given journalID.
     
     - parameter withID: journalID in database for the journal that needs to be retrieved
     - parameter withBlock: closure to be called
     - parameter Journal: journal to be used
     
     */
    static func getJournal(withId: String, withBlock: @escaping (Journal) -> Void) {
        FIRDatabase.database().reference().child("Journals/\(withId)").observe(.value, with: { snapshot in
            if snapshot.exists() {
                if let journalDict = snapshot.value as? [String: Any] {
                    let retrievedJournal = Journal(key: snapshot.key, journalDict: journalDict)
                    withBlock(retrievedJournal)
                }
            } else {
                print ("Cannot get journal")
            }
        })
    }
    
    /**
     Poll for invites for the current user from the database one by one.
     
     - parameter withBlock: closure to call
     - parameter Invite: invite to use
     
     */
    static func pollForInvites(withIds: [String], withBlock: @escaping (Invite) -> Void) {
        for invID in withIds {
            FIRDatabase.database().reference().child("Invites/\(invID)").observe(.value, with: { snapshot in
                if snapshot.exists() {
                    if let inviteDict = snapshot.value as? [String: Any] {
                        let retrievedInvite = Invite(key: snapshot.key, inviteDict: inviteDict)
                        withBlock(retrievedInvite)
                    }
                } else {
                    print("Cannot access invite")
                }
            })
        }
    }
    
    /**
     Poll for journals for the current user from the database one by one.
     
     - parameter withBlock: closure to call
     - parameter Journal: journal to use
     
     */
    static func pollForJournals(withIds: [String], withBlock: @escaping (Journal) -> Void) {
        let dbRef = FIRDatabase.database().reference()
        for journalID in withIds {
            print("journal id is")
            print(journalID)
            dbRef.child("Journals/\(journalID)").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let journalDict = snapshot.value as? [String: Any] {
                        let retrievedJournal = Journal(key: snapshot.key, journalDict: journalDict as [String : AnyObject])
                        withBlock(retrievedJournal)
                    }
                } else {
                    print("Cannot access Journal")
                }
            })
        }
    }
    /**
     Stores the device token in the database for use with push notifications if it is not already there.
     */

    static func updateTokenIfNeeded() {
        if let user = FIRAuth.auth()?.currentUser {
            let ref = FIRDatabase.database().reference()
            ref.child("notification_ids/\((user.uid))").observeSingleEvent(of: .value, with: { (snapshot) in
                if FIRInstanceID.instanceID().token() == nil {
                    return
                }
                if snapshot.exists() {
                    let notificationIDsArray = snapshot.value as! NSMutableArray
                    
                    if notificationIDsArray.index(of: FIRInstanceID.instanceID().token()!) == NSNotFound {
                        notificationIDsArray.add(FIRInstanceID.instanceID().token()!)
                        
                        ref.child("notification_ids/\(user.uid)").setValue(notificationIDsArray)
                    }
                } else {
                    let saveArray: NSArray = NSArray(object: FIRInstanceID.instanceID().token()!)
                    ref.child("notification_ids/\(user.uid)").setValue(saveArray)
                }
                
            }) { (error) in
                NSLog("user notification load error")
                NSLog(error.localizedDescription)
            }
        } else {
            print("not signed in")
        }
    }
}
