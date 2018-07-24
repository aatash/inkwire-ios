//
//  ImagePostCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/28/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class ImagePostCollectionViewCell: PostCollectionViewCell {
 
    var imageView: UIImageView!
    
    override func setupCell(withAttr: PostCellSizeAttributes) {
        super.setupCell(withAttr: withAttr)
        imageView = UIImageView(frame: CGRect(x: PostCellSettings.leftMargin, y: 20, width: frame.width - PostCellSettings.leftMargin - 10, height: PostCellSettings.imageViewHeight))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
    }
}
