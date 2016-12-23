//
//  TextDetailCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import KILabel
class TextDetailCollectionViewCell: PostDetailCollectionViewCell {
    
    var contentLabel: KILabel!
    
    override func setupCell(withAttr: PostDetailCellSizeAttributes) {
        super.setupCell(withAttr: withAttr)
        contentLabel = KILabel(frame: CGRect(x: PostDetailCellSettings.leftMargin, y: 15, width: contentView.frame.width - PostDetailCellSettings.leftMargin - PostDetailCellSettings.rightMargin, height: withAttr.contentLabelHeight!))
        contentLabel.font = PostCellSettings.contentLabelFont
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.darkGray
        contentLabel.urlLinkTapHandler = { label, url, range in
            self.delegate?.urlTapped(url: url)
        }
        containerView.addSubview(contentLabel)
    }
    
}
