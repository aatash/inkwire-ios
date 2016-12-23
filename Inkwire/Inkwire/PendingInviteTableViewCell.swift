//
//  PendingInviteTableViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

protocol PendingInviteTableViewCellDelegate {
    func accept(invite: Invite)
    func reject(invite: Invite)
}

class PendingInviteTableViewCell: UITableViewCell {
    
    var profPicImageView: UIImageView!
    var usernameLabel: UILabel!
    var journalNameLabel: UILabel!
    var acceptButton: UIButton!
    var rejectButton: UIButton!
    var invite: Invite?
    var delegate: PendingInviteTableViewCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpProfilePic()
        setUpButtons()
        setUpLabels()
    }
    
    func acceptButtonTapped() {
        delegate?.accept(invite: invite!)
    }
    
    func rejectButtonTapped() {
        delegate?.reject(invite: invite!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUpProfilePic() {
        profPicImageView = UIImageView(frame: CGRect(x: 17, y: (frame.height - 40)/2, width: 40, height: 40))
        profPicImageView.layer.cornerRadius = profPicImageView.frame.height/2
        profPicImageView.clipsToBounds = true
        profPicImageView.contentMode = .scaleAspectFill
        contentView.addSubview(profPicImageView)
    }

    /** 
     Setup UI for buttons that accept and reject invitations.
     */
    func setUpButtons() {
        acceptButton = UIButton(frame: CGRect(x: frame.width - 100, y: (frame.height - 35)/2, width: 35, height: 35))
        acceptButton.layer.cornerRadius = acceptButton.frame.width/2
        acceptButton.clipsToBounds = true
        acceptButton.backgroundColor = UIColor(hex: "#22C69B")
        acceptButton.tintColor = UIColor.white
        acceptButton.setImage(UIImage(named: "check")?.withRenderingMode(.alwaysTemplate), for: .normal)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        contentView.addSubview(acceptButton)
        
        rejectButton = UIButton(frame: CGRect(x: acceptButton.frame.maxX + 10, y: (frame.height - 35)/2, width: 35, height: 35))
        rejectButton.layer.cornerRadius = acceptButton.frame.width/2
        rejectButton.clipsToBounds = true
        rejectButton.backgroundColor = UIColor(hex: "#FB4563")
        rejectButton.tintColor = UIColor.white
        rejectButton.setImage(UIImage(named: "reject")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
        contentView.addSubview(rejectButton)
    }
    
    /** 
     Setup UI for username and journal name labels next to the profile picture.
    */
    func setUpLabels() {
        usernameLabel = UILabel(frame: CGRect(x: profPicImageView.frame.maxX + 10, y: profPicImageView.frame.minY - 2, width: acceptButton.frame.minX - profPicImageView.frame.maxX - 10, height: 21))
        usernameLabel.textColor = UIColor.darkGray
        usernameLabel.font = UIFont(name: "SFUIText-Regular", size: 17)
        contentView.addSubview(usernameLabel)
        
        journalNameLabel = UILabel(frame: CGRect(x: profPicImageView.frame.maxX + 10, y: usernameLabel.frame.maxY + 2, width: acceptButton.frame.minX - profPicImageView.frame.maxX - 10, height: 21))
        journalNameLabel.textColor = UIColor.lightGray
        journalNameLabel.font = UIFont(name: "SFUIText-Medium", size: 14)
        contentView.addSubview(journalNameLabel)
    }
}
