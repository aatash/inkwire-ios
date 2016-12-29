//
//  MenuController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import SWRevealViewController
import Firebase


class MenuController: UIViewController, SWRevealViewControllerDelegate {
    
    var tableView: UITableView!
    var icons = [UIImage(named: "myJournals"), UIImage(named: "inviteIcon"), UIImage(named: "settings")]
    var optionLabels = ["Journals", "Invites", "Settings"]
    var segueIdentifiers = ["toJournalsFromMenu", "toInvitesFromMenu", "toSettingsFromMenu"]
    var cells = [MenuOptionTableViewCell]()
    var overlayView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView = UIView(frame: CGRect(x: 0, y: 64, width: view.frame.width, height: view.frame.height))
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.revealViewController().frontViewController.view.addSubview(overlayView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        overlayView.removeFromSuperview()
    }
    override func viewWillAppear(_ animated: Bool) {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        InkwireDBUtils.getUser(withId: currUserId!, withBlock: { currUser -> Void in
            DispatchQueue.main.async {
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! HeaderTableViewCell
                cell.usernameLabel.text = currUser.name!
                cell.emailLabel.text = currUser.email!
                currUser.getProfPic(withBlock: { retrievedImage -> Void in
                    cell.profPicImageView.image = retrievedImage
                })
            }
        })
    }

    
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.register(HeaderTableViewCell.self, forCellReuseIdentifier: "headerCell")
        tableView.register(MenuOptionTableViewCell.self, forCellReuseIdentifier: "menuCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MenuController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderTableViewCell
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            cell.awakeFromNib()
            
            let currUserId = FIRAuth.auth()?.currentUser?.uid
            InkwireDBUtils.getUser(withId: currUserId!, withBlock: { currUser -> Void in
                DispatchQueue.main.async {
                    cell.usernameLabel.text = currUser.name!
                    cell.emailLabel.text = currUser.email!
                    currUser.getProfPic(withBlock: { retrievedImage -> Void in
                        cell.profPicImageView.image = retrievedImage
                    })
                }
            })
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuOptionTableViewCell
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            cell.awakeFromNib()
            
            cell.icon.image = icons[indexPath.item]?.withRenderingMode(.alwaysTemplate)
            cell.vcLabel.text = optionLabels[indexPath.item]
            
            if cells.count < indexPath.item + 1 {
                cells.append(cell)
            }
            
            if indexPath.item == 0 {
                cell.select()
            }
            
            if indexPath.item == 1 {
                InkwireDBUtils.checkNumPendingInvites(withBlock: { numPending -> Void in
                    if numPending > 0 {
                        cell.vcLabel.sizeToFit()
                        cell.addBadge(withValue: numPending)
                    }
                })
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 175
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        for cell in cells {
            if cells.index(of: cell) == indexPath.item {
                cell.select()
            } else {
                cell.unselect()
            }
        }
        
        performSegue(withIdentifier: segueIdentifiers[indexPath.item], sender: self)
    }
}
