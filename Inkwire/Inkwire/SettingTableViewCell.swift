//
//  SettingTableViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    var icon: UIImageView!
    var actionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpIcon()
        setUpActionName()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpIcon() {
        icon = UIImageView(frame: CGRect(x: 20, y: 13, width: 23, height: 23))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = UIColor(hex: "#B5BCC1")
        contentView.addSubview(icon)
    }
    
    func setUpActionName() {
        actionName = UILabel(frame: CGRect(x: 16 + icon.frame.maxX, y: icon.frame.minY + 1, width: 200, height: 18))
        actionName.textColor = UIColor.darkGray
        actionName.font = UIFont(name: "SFUIText-Regular", size: 16)
        contentView.addSubview(actionName)
    }
    
    /*
     func setUpArrowIcon() {
     arrowIcon = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 24, y: (self.frame.height - 13)/2, width: 13, height: 13))
     }
     */
}
