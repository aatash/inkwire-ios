//
//  PostDetailCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

struct PostDetailCellSettings {
    static let contentLabelFont = UIFont(name: "SFUIText-Regular", size: 14)
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    static let imageViewHeight: CGFloat = 270
}

protocol PostDetailCollectionViewCellDelegate {
    func urlTapped(url: String)
}

class PostDetailCollectionViewCell: UICollectionViewCell {
    
    var containerView: UIView!
    var profPicImageView: UIImageView!
    var usernameLabel: UILabel!
    var likeButton: UIButton!
    var likesLabel: UILabel!
    var commentButton: UIButton!
    var commentsLabel: UILabel!
    var liked = false
    var post: Post?
    var delegate: PostDetailCollectionViewCellDelegate? = nil
    
    func setupCell(withAttr: PostDetailCellSizeAttributes) {
        
        backgroundColor = UIColor.white
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: withAttr.cellContainerHeight!))
        containerView.backgroundColor = UIColor.clear
        contentView.addSubview(containerView)
        
        profPicImageView = UIImageView(frame: CGRect(x: PostDetailCellSettings.leftMargin, y: containerView.frame.maxY + 15, width: 25, height: 25))
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        profPicImageView.clipsToBounds = true
        profPicImageView.contentMode = .scaleAspectFill
        contentView.addSubview(profPicImageView)
        
        usernameLabel = UILabel(frame: CGRect(x: profPicImageView.frame.maxX + 10, y: profPicImageView.frame.minY + 3, width: contentView.frame.width - 130 - 10 - profPicImageView.frame.maxX - 10, height: 19))
        usernameLabel.font = UIFont(name: "SFUIText-Medium", size: 13)
        usernameLabel.textColor = Constants.likeColor
        contentView.addSubview(usernameLabel)
        
        likeButton = UIButton(frame: CGRect(x: contentView.frame.width - 130, y: usernameLabel.frame.minY, width: 19, height: 19))
        likeButton.contentMode = .scaleAspectFit
        likeButton.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysTemplate), for: .normal)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        likeButton.tintColor = Constants.unlikeColor
        contentView.addSubview(likeButton)
        
        likesLabel = UILabel(frame: CGRect(x: likeButton.frame.maxX + 5, y: likeButton.frame.minY, width: 30, height: 19))
        likesLabel.font = UIFont(name: "SFUIText-Bold", size: 13)
        likesLabel.textColor = Constants.unlikeColor
        contentView.addSubview(likesLabel)
        
        commentButton = UIButton(frame: CGRect(x: likesLabel.frame.maxX + 15, y: usernameLabel.frame.minY, width: 19, height: 19))
        commentButton.contentMode = .scaleAspectFit
        commentButton.tintColor = Constants.unlikeColor
        commentButton.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        contentView.addSubview(commentButton)
        
        commentsLabel = UILabel(frame: CGRect(x: commentButton.frame.maxX + 5, y: commentButton.frame.minY, width: 30, height: 19))
        commentsLabel.font = UIFont(name: "SFUIText-Bold", size: 13)
        commentsLabel.textColor = Constants.unlikeColor
        contentView.addSubview(commentsLabel)
        
        let bottomSeparator = UIView(frame: CGRect(x: 30, y: frame.height - 5, width: frame.width - 60, height: 1))
        bottomSeparator.backgroundColor = Constants.postSeparatorColor
        contentView.addSubview(bottomSeparator)
    }

    func setLiked() {
        likeButton.tintColor = Constants.likeColor
        likesLabel.textColor = Constants.likeColor
        liked = true
    }
    
    func setUnliked() {
        likeButton.tintColor = Constants.unlikeColor
        likesLabel.textColor = Constants.unlikeColor
        liked = false
    }
    
    func likeButtonTapped() {
        if !liked {
            post?.like()
            setLiked()
            if let likes = Int(likesLabel.text!) {
                let newLikes = likes + 1
                likesLabel.text = String(newLikes)
            }
        } else {
            post?.unlike()
            setUnliked()
            if let likes = Int(likesLabel.text!) {
                let newLikes = likes - 1
                likesLabel.text = String(newLikes)
            }
        }
    }
}
