//
//  ImageDetailCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class ImageDetailCollectionViewCell: PostDetailCollectionViewCell {
    var imageView: UIImageView!
    
    override func setupCell(withAttr: PostDetailCellSizeAttributes) {
        super.setupCell(withAttr: withAttr)
        imageView = UIImageView(frame: CGRect(x: 0, y: 20, width: frame.width, height: PostDetailCellSettings.imageViewHeight))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
    }
}
