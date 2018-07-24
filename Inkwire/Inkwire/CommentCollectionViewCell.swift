//
//  CommentCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

struct CommentCellSettings {
    static let contentLabelFont = UIFont(name: "SFUIText-Light", size: 14)
    static let leftMargin: CGFloat = 75
    static let rightMargin: CGFloat = 10
}

class CommentCollectionViewCell: UICollectionViewCell {
    
    var profPicImageView: UIImageView!
    var usernameLabel: UILabel!
    var contentLabel: UILabel!
    
    func setupCell(withAttr: CommentCellSizeAttributes) {
        backgroundColor = UIColor.white
        
        profPicImageView = UIImageView(frame: CGRect(x: 30, y: 10, width: 35, height: 35))
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        profPicImageView.clipsToBounds = true
        profPicImageView.contentMode = .scaleAspectFill
        contentView.addSubview(profPicImageView)
        
        usernameLabel = UILabel(frame: CGRect(x: CommentCellSettings.leftMargin, y: profPicImageView.frame.minY - 2, width: contentView.frame.width - 130 - 10 - profPicImageView.frame.maxX - 10, height: 19))
        usernameLabel.font = UIFont(name: "SFUIText-Regular", size: 14)
        usernameLabel.textColor = UIColor.darkGray
        contentView.addSubview(usernameLabel)
        
        contentLabel = UILabel(frame: CGRect(x: CommentCellSettings.leftMargin, y: usernameLabel.frame.maxY + 2, width: contentView.frame.width - CommentCellSettings.leftMargin - CommentCellSettings.rightMargin, height: withAttr.contentLabelHeight!))
        contentLabel.font = CommentCellSettings.contentLabelFont
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.darkGray
        contentView.addSubview(contentLabel)
    }
}
