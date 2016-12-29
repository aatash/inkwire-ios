//
//  HeaderTableViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    var profPicImageView: UIImageView!
    var usernameLabel: UILabel!
    var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = UIColor.white
        setUpProfilePic()
        setUpUserNameLabel()
        setUpEmailLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setUpProfilePic() {
        profPicImageView = UIImageView(frame: CGRect(x: 60, y: 25, width: 80, height: 80))
        profPicImageView.contentMode = .scaleAspectFill
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        profPicImageView.clipsToBounds = true
        contentView.addSubview(profPicImageView)
    }
    
    func setUpUserNameLabel() {
        usernameLabel = UILabel(frame: CGRect(x: 10, y: profPicImageView.frame.maxY + 10, width: 190, height: 20))
        usernameLabel.font = UIFont(name: "SFUIText-Medium", size: 16)
        usernameLabel.textAlignment = .center
        usernameLabel.textColor = Constants.likeColor
        contentView.addSubview(usernameLabel)
    }
    
    func setUpEmailLabel() {
        emailLabel = UILabel(frame: CGRect(x: 10, y: usernameLabel.frame.maxY + 2, width: 190, height: 20))
        emailLabel.font = UIFont(name: "SFUIText-Regular", size: 13)
        emailLabel.textAlignment = .center
        emailLabel.textColor = UIColor.lightGray
        contentView.addSubview(emailLabel)
    }
}
