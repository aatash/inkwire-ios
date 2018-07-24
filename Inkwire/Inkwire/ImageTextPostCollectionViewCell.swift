//
//  PostCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit
import KILabel
class ImageTextPostCollectionViewCell: PostCollectionViewCell {
    
    var contentLabel: KILabel!
    var imageView: UIImageView!
    
    override func setupCell(withAttr: PostCellSizeAttributes) {
        super.setupCell(withAttr: withAttr)
        contentLabel = KILabel(frame: CGRect(x: PostCellSettings.leftMargin, y: 10, width: contentView.frame.width - PostCellSettings.leftMargin - PostCellSettings.rightMargin, height: withAttr.contentLabelHeight!))
        contentLabel.font = PostCellSettings.contentLabelFont
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.darkGray
        contentLabel.urlLinkTapHandler = { label, url, range in
            self.delegate?.urlTapped(url: url)
        }
        containerView.addSubview(contentLabel)
        
        imageView = UIImageView(frame: CGRect(x: PostCellSettings.leftMargin, y: contentLabel.frame.maxY + 10, width: frame.width - PostCellSettings.leftMargin - 10, height: PostCellSettings.imageViewHeight))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
    }
}
