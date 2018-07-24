//
//  UserTableViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    var profPicImageView: UIImageView!
    var nameLabel: UILabel!
    var selectView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        profPicImageView = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        profPicImageView.clipsToBounds = true
        profPicImageView.contentMode = .scaleAspectFill
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        contentView.addSubview(profPicImageView)
        
        nameLabel = UILabel(frame: CGRect(x: profPicImageView.frame.maxX + 10, y: 0, width: self.frame.width - profPicImageView.frame.maxX - 10 - 40, height: 19))
        nameLabel.center.y = profPicImageView.center.y
        nameLabel.font = UIFont(name: "SFUIText-Regular", size: 15)
        nameLabel.textColor = UIColor.black
        contentView.addSubview(nameLabel)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
