//
//  Invite.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import Firebase

class Invite {
    
    var senderId: String?
    var receiverId: String?
    var journalId: String?
    var isContributor: Bool?
    var inviteId: String?
    let dbRef = FIRDatabase.database().reference()
    
    /**
     Initialize an invite object using dictionary retrieved from database.
     
     - parameter key: id of the invite
     - parameter inviteDict: dictionary containing all information about the invite
     
     */
    convenience init(key: String, inviteDict: [String: Any]) {
        self.init()
        inviteId = key
        if let inviteSenderId = inviteDict["senderId"] as? String {
            senderId = inviteSenderId
        }
        if let inviteReceiverId = inviteDict["receiverId"] as? String {
            receiverId = inviteReceiverId
        }
        if let inviteJournalId = inviteDict["journalId"] as? String {
            journalId = inviteJournalId
        }
        if let inviteIsContributor = inviteDict["isContributor"] as? Bool {
            isContributor = inviteIsContributor
        }
    }
    
    /**
     Initialize an invite object using a receiveId, journalId, and users status of contribution.
     
     - parameter receiverIdValue: id of the receiver of the invite
     - parameter isAContributor: whether or not the user is a contributor or not
     - parameter journalIdValue: id of the journal to be invited to
     
     */
    convenience init(receiverIdValue: String, isAContributor: Bool, journalIdValue: String) {
        self.init()
        senderId = FIRAuth.auth()?.currentUser?.uid
        receiverId = receiverIdValue
        isContributor = isAContributor
        journalId = journalIdValue
    }
    
    /**
     Gets the sender of the invite from the database.
     
     - parameter withBlock: closure to call
     - parameter User: user who posted to the comment to use
     
     */
    func getSender(withBlock: @escaping (User?) -> Void) {
        InkwireDBUtils.getUser(withId: senderId!, withBlock: { retrievedUser -> Void in
            withBlock(retrievedUser)
        })
    }
    
    /**
     Accept the invitation.
     
     - parameter withBlock: closure to call
     - parameter success: boolean to use
     
     */
    func accept(withBlock: @escaping (_ success: Bool) -> Void) {
        modifyReceiverDataOnAccept(withBlock: { modifySuccess -> Void in
            if modifySuccess {
                self.deleteFromDatabase(withBlock: { deleteSuccess -> Void in
                    if deleteSuccess {
                        withBlock(true)
                    }
                })
            }
        })
    }
    
    /**
     Modify the reciever data in the database upon accepting an invitation.
     
     - parameter withBlock: closure to call
     - parameter Bool: boolean to use
     
     */
    private func modifyReceiverDataOnAccept(withBlock: @escaping (Bool) -> Void) {
        InkwireDBUtils.getUser(withId: receiverId!, withBlock: { retrievedReceiver -> Void in
            let index = retrievedReceiver.receivedInviteIds?.index(of: self.inviteId!)
            if index != nil {
                retrievedReceiver.receivedInviteIds?.remove(at: index!)
            }
            retrievedReceiver.journalIds?.append(self.journalId!)
            retrievedReceiver.saveToDB(withBlock: { savedUser -> Void in
                InkwireDBUtils.getJournal(withId: self.journalId!, withBlock: { retrievedJournal -> Void in
                    if self.isContributor! {
                        retrievedJournal.contributorIds?.append(self.receiverId!)
                        if (retrievedJournal.observerIds?.contains(self.receiverId!))! {
                            retrievedJournal.observerIds?.remove(object: self.receiverId!)
                        }
                    } else {
                        retrievedJournal.observerIds?.append(self.receiverId!)
                    }
                    retrievedJournal.saveToDB(withBlock: { savedJournal -> Void in
                        withBlock(true)
                    })
                })
            })
        })
    }
    
    /**
     Modify the reciever data in the database upon rejecting an invitation.
     
     - parameter withBlock: closure to call
     - parameter Bool: boolean to use
     
     */
    private func modifyReceiverDataOnReject(withBlock: @escaping (Bool) -> Void) {
        InkwireDBUtils.getUser(withId: receiverId!, withBlock: { retrievedReceiver -> Void in
            if let index = retrievedReceiver.receivedInviteIds?.index(of: self.inviteId!) {
                retrievedReceiver.receivedInviteIds?.remove(at: index)
            }
            retrievedReceiver.saveToDB(withBlock: { savedUser -> Void in
                withBlock(true)
            })
        })
    }
    
    /**
     Reject the invitation and delete it from the database
     
     - parameter withBlock: closure to call
     - parameter success: boolean to use
     
     */
    func reject(withBlock: @escaping (_ success: Bool) -> Void)  {
        modifyReceiverDataOnReject(withBlock: { modifySuccess -> Void in
            if modifySuccess {
                self.deleteFromDatabase(withBlock: { deleteSuccess -> Void in
                    if deleteSuccess {
                        withBlock(true)
                    }
                })
            }
        })
    }
    
    /**
     Delete the invitation from the database.
     
     - parameter withBlock: closure to call
     - parameter Bool: boolean to use
     
     */
    private func deleteFromDatabase(withBlock: @escaping (Bool) -> Void) {
        if inviteId != nil {
            let inviteRef = FIRDatabase.database().reference().child("Invites/\(inviteId)")
            inviteRef.removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    withBlock(false)
                } else {
                    withBlock(true)
                }
            })
        } else {
            withBlock(false)
        }
    }
    
    /**
     Sends invitation to receiver of invitation.  Also sends push notification to receiver.
     
     - parameter withBlock: closure to call
     - parameter Bool: boolean to use
     
     */
    func send(withBlock: @escaping (Bool) -> Void) {
        if inviteId == nil {
            inviteId = dbRef.child("Invites").childByAutoId().key
        }
        //TODO: send push notification
        var contributorVal = 0
        if isContributor! {
            contributorVal = 1
        }
        let inviteDict: [String: Any] = ["senderId": senderId!,
                                         "receiverId": receiverId!,
                                         "journalId": journalId!,
                                         "isContributor": contributorVal]
        
        let notificationId = dbRef.child("notifications/").childByAutoId().key
        
        let notificationMessage = "You received a new invite!"
        
        let notificationDict: [String: Any] = ["attempts": 0,
                                               "key": notificationId,
                                               "message": notificationMessage,
                                               "read": false,
                                               "sent": false,
                                               "senderUID": senderId!,
                                               "recipientUID": receiverId!,
                                               "time": String(describing: Date())]
        
        dbRef.child("notifications/").updateChildValues([notificationId: notificationDict])
        
        dbRef.child("Invites/").updateChildValues([inviteId!: inviteDict], withCompletionBlock: { (error, ref) -> Void in
            if error != nil {
                print("An error occurred while sending the invite: \(error)")
                withBlock(false)
            } else {
                InkwireDBUtils.getUser(withId: self.receiverId!, withBlock: { receiver -> Void in
                    receiver.receivedInviteIds?.append(self.inviteId!)
                    receiver.saveToDB(withBlock: { updatedUser -> Void in
                        withBlock(true)
                    })
                })
            }
        })
    }
}
