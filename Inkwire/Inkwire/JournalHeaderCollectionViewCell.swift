//
//  JournalHeaderCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

struct HeaderCellSettings {
    static let contentLabelFont = UIFont(name: "SFUIText-Light", size: 14)
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
}

class JournalHeaderCollectionViewCell: UICollectionViewCell {
    
    var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.white
        let bottomSeparator = UIView(frame: CGRect(x: 30, y: frame.height - 5, width: frame.width - 60, height: 1))
        bottomSeparator.backgroundColor = Constants.postSeparatorColor
        contentView.addSubview(bottomSeparator)
    }
    
    func setupCell(withAttr: JournalCellSizeAttributes) {
        descriptionLabel = UILabel(frame: CGRect(x: HeaderCellSettings.leftMargin, y: (frame.height - 5 - withAttr.descriptionLabelHeight!)/2, width: frame.width - 40, height: withAttr.descriptionLabelHeight!))
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.font = UIFont(name: "SFUIText-Light", size: 14)
        descriptionLabel.textColor = UIColor.darkGray
        descriptionLabel.textAlignment = .center
        contentView.addSubview(descriptionLabel)
    }
}
