//
//  MenuOptionTableViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

class MenuOptionTableViewCell: UITableViewCell {
    
    var icon: UIImageView!
    var vcLabel: UILabel!
    var unselectedColor = UIColor(hex: "#A6B6C2")
    var selectedColor = UIColor.white
    var badge: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = UIColor.white
        
        icon = UIImageView(frame: CGRect(x: 20, y: (frame.height - 30)/2, width: 30, height: 30))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = unselectedColor
        contentView.addSubview(icon)
        
        vcLabel = UILabel(frame: CGRect(x: 70, y: (frame.height - 20)/2, width: 120, height: 20))
        vcLabel.font = UIFont(name: "SFUIText-Medium", size: 17)
        vcLabel.textColor = unselectedColor
        contentView.addSubview(vcLabel)
    }
    
    func addBadge(withValue: Int) {
        badge = UILabel(frame: CGRect(x: vcLabel.frame.maxX - 3, y: vcLabel.frame.minY - 7, width: 20, height: 20))
        badge.layer.cornerRadius = badge.frame.height/2
        badge.clipsToBounds = true
        badge.backgroundColor = UIColor.red
        badge.textColor = UIColor.white
        badge.textAlignment = .center
        badge.text = String(withValue)
        badge.font = UIFont(name: "SFUIText-Regular", size: 10)
        contentView.addSubview(badge)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     Change colors of background and items in sidebar upon selecting a sidebar item
     */
    func select() {
        backgroundColor = Constants.appColor
        icon.tintColor = selectedColor
        vcLabel.textColor = selectedColor
    }
    
    func unselect() {
        backgroundColor = UIColor.white
        icon.tintColor = unselectedColor
        vcLabel.textColor = unselectedColor
    }
}
