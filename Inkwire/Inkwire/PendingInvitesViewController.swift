//
//  PendingInvitesViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import Firebase
import BBBadgeBarButtonItem
class PendingInvitesViewController: UIViewController {
    
    var invites = [Invite]()
    var numInvites = 0
    var tableView: UITableView!
    var menuButton: BBBadgeBarButtonItem!
    var negativeStateView: PendingInvitesNegativeStateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.fixedHeightWhenStatusBarHidden = true
        
        setupNavBar()
        setUpTableView()
        setupNegativeStateView()
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        InkwireDBUtils.getUser(withId: currUserId!, withBlock: { currUser -> Void in
            
            if currUser.receivedInviteIds?.count == 0 {
                self.showNegativeStateView()
                return
            }
            
            InkwireDBUtils.pollForInvites(withIds: currUser.receivedInviteIds!, withBlock: { retrievedInvite -> Void in
                var indexPaths = [IndexPath]()
                if self.invites.index(where: {$0.inviteId == retrievedInvite.inviteId}) != nil {
                    return
                }
                
                self.invites.append(retrievedInvite)
                let index = self.invites.index(where: {$0.inviteId == retrievedInvite.inviteId})
                indexPaths.append(IndexPath(item: index!, section: 0))
                
                DispatchQueue.main.async {
                    if self.negativeStateView.superview != nil {
                        self.hideNegativeStateView()
                    }
                    self.numInvites += 1
                    self.tableView.insertRows(at: indexPaths, with: .fade)
                }
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        InkwireDBUtils.checkNumPendingInvites(withBlock: { numPending -> Void in
            if numPending > 0 {
                self.menuButton.badgeValue = String(numPending)
                self.menuButton.badgeOriginX = 17
                self.menuButton.badgeOriginY = -2
                self.menuButton.badgeBGColor = UIColor.red
            }
        })
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = Constants.appColor
        navigationController?.navigationBar.tintColor = UIColor.white
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        customButton.setImage(UIImage(named: "hamburgerMenu"), for: .normal)
        
        if revealViewController() != nil {
            customButton.addTarget(revealViewController(), action: Selector(("revealToggle:")), for: .touchUpInside)
            
            revealViewController().rearViewRevealWidth = 200
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        menuButton = BBBadgeBarButtonItem(customUIButton: customButton)
        navigationItem.leftBarButtonItem = menuButton
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.title = "Invites"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        navigationController?.navigationBar.layer.shadowColor = Constants.navBarShadowColor.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.9
        navigationController?.navigationBar.layer.shadowRadius = 2
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2, height: 2)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func setupNegativeStateView() {
        negativeStateView = PendingInvitesNegativeStateView(frame: view.frame)
    }
    
    func showNegativeStateView() {
        tableView.isHidden = true
        view.addSubview(negativeStateView)
    }
    
    func hideNegativeStateView() {
        negativeStateView.removeFromSuperview()
        tableView.isHidden = false
    }

    func setUpTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.register(PendingInviteTableViewCell.self, forCellReuseIdentifier: "inviteCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PendingInvitesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numInvites
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath)
            as! PendingInviteTableViewCell
        
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        
        cell.awakeFromNib()
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PendingInviteTableViewCell
        
        let invite = invites[indexPath.item]
        cell.invite = invite
        invite.getSender(withBlock: { sender -> Void in
            cell.usernameLabel.text = sender?.name!
            sender?.getProfPic(withBlock: { retrievedImage -> Void in
                cell.profPicImageView.image = retrievedImage
            })
        })
        
        InkwireDBUtils.getJournal(withId: invite.journalId!, withBlock: { retrievedJournal -> Void in
            var labelText = retrievedJournal.title!
            if invite.isContributor! {
                labelText += " (invited as contributor"
            } else {
                labelText += " (invited as observer"
            }
            cell.journalNameLabel.text = retrievedJournal.title!
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

// MARK: - PendingInviteTableViewCellDelegate
extension PendingInvitesViewController: PendingInviteTableViewCellDelegate {
    func accept(invite: Invite) {
        invite.accept(withBlock: { success -> Void in
            if success {
                DispatchQueue.main.async {
                    var indexPaths = [IndexPath]()
                    if let index = self.invites.index(where: {$0.inviteId == invite.inviteId}) {
                        indexPaths.append(IndexPath(row: index, section: 0))
                        self.invites.remove(at: index)
                        self.numInvites -= 1
                        self.tableView.deleteRows(at: indexPaths, with: .fade)
                    }
                }
            } else {
                print("unable to accept invite")
            }
        })
    }
    
    func reject(invite: Invite) {
        invite.reject(withBlock: { success -> Void in
            if success {
                DispatchQueue.main.async {
                    var indexPaths = [IndexPath]()
                    if let index = self.invites.index(where: {$0.inviteId == invite.inviteId}) {
                        indexPaths.append(IndexPath(row: index, section: 0))
                        self.invites.remove(at: index)
                        self.numInvites -= 1
                        self.tableView.deleteRows(at: indexPaths, with: .fade)
                    }
                }
            } else {
                print("unable to reject invite")
            }
        })
    }
}
