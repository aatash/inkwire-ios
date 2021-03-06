//
//  JournalCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class JournalCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var contributorsLabel: UILabel!
    var purpleColor = UIColor(hexString: "#5B27A8")?.cgColor
    
    override func awakeFromNib() {
        
        backgroundColor = UIColor.white
        layer.cornerRadius = 2
        layer.masksToBounds = false
        layer.shadowColor = UIColor(hexString: "#D1CDCD")?.cgColor
        layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        layer.shadowRadius = 1.5
        layer.shadowOpacity = 0.9
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 140))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRect(x: 5, y: imageView.frame.maxY + 5, width: frame.width - 10, height: 35))
        titleLabel.textColor = Constants.appColor
        titleLabel.font = UIFont(name: "SFUIText-Regular", size: 13)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        contributorsLabel = UILabel(frame: CGRect(x: 5, y: titleLabel.frame.maxY, width: frame.width - 10, height: 20))
        contributorsLabel.textColor = Constants.appColor
        contributorsLabel.font = UIFont(name: "SFUIText-Medium", size: 11)
        contributorsLabel.textAlignment = .center
        contentView.addSubview(contributorsLabel)
        
        
    }
}
