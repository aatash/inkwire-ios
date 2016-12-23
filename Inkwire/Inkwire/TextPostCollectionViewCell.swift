//
//  TextPostCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/28/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import KILabel

class TextPostCollectionViewCell: PostCollectionViewCell {
 
    var contentLabel: KILabel!
    
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
    }
    
}
