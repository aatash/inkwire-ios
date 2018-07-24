//
//  PostCollectionViewCell.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/17/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

struct PostCellSettings {
    static let contentLabelFont = UIFont(name: "SFUIText-Regular", size: 14)
    static let leftMargin: CGFloat = 80
    static let rightMargin: CGFloat = 20
    static let imageViewHeight: CGFloat = 140
}

protocol PostCollectionViewCellDelegate {
    func urlTapped(url: String)
}

class PostCollectionViewCell: UICollectionViewCell {
    
    var containerView: UIView!
    var dayLabel: UILabel!
    var monthLabel: UILabel!
    var profPicImageView: UIImageView!
    var usernameLabel: UILabel!
    var likeButton: UIButton!
    var likesLabel: UILabel!
    var commentButton: UIButton!
    var commentsLabel: UILabel!
    var timeBubble: UIView!
    var liked = false
    var post: Post?
    var delegate: PostCollectionViewCellDelegate? = nil
    
    func setupCell(withAttr: PostCellSizeAttributes) {
        
        backgroundColor = UIColor.white
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: withAttr.cellContainerHeight!))
        containerView.backgroundColor = UIColor.clear
        contentView.addSubview(containerView)
        
        profPicImageView = UIImageView(frame: CGRect(x: PostCellSettings.leftMargin, y: containerView.frame.maxY + 15, width: 25, height: 25))
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
        
        let bottomSeparator = UIView(frame: CGRect(x: profPicImageView.frame.minX, y: frame.height - 5, width: frame.width - profPicImageView.frame.minX, height: 1))
        bottomSeparator.backgroundColor = Constants.postSeparatorColor
        contentView.addSubview(bottomSeparator)
        
        setupTimeBubble()
    }
    
    func setupTimeBubble() {
        timeBubble = UIView(frame: CGRect(x: 10, y: (frame.height - 50)/2, width: 50, height: 50))
        timeBubble.layer.cornerRadius = timeBubble.frame.width/2
        timeBubble.clipsToBounds = false
        timeBubble.backgroundColor = UIColor.white
        timeBubble.layer.shadowColor = UIColor(hex: "#B6B6B6").cgColor
        timeBubble.layer.shadowOffset = CGSize(width: 2, height: 2)
        timeBubble.layer.shadowRadius = 2
        timeBubble.layer.shadowOpacity = 0.6
        timeBubble.layer.masksToBounds = false
        contentView.addSubview(timeBubble)
        
        dayLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 50, height: 15))
        dayLabel.textColor = Constants.appColor
        dayLabel.font = UIFont(name: "SFUIText-Light", size: 17)
        dayLabel.textAlignment = .center
        dayLabel.adjustsFontSizeToFitWidth = true
        timeBubble.addSubview(dayLabel)
        
        monthLabel = UILabel(frame: CGRect(x: 0, y: dayLabel.frame.maxY - 2, width: 50, height: 25))
        monthLabel.textColor = UIColor(hex: "#C9D0D5")
        monthLabel.font = UIFont(name: "SFUIText-Regular", size: 10)
        monthLabel.textAlignment = .center
        monthLabel.adjustsFontSizeToFitWidth = true
        timeBubble.addSubview(monthLabel)
        
    }
    
    func includeBottomConnector() {
        let bottomConnector = UIView(frame: CGRect(x: timeBubble.frame.midX - 1, y: timeBubble.frame.maxY + 4, width: 2, height: frame.height - timeBubble.frame.maxY - 4))
        bottomConnector.backgroundColor = Constants.postSeparatorColor
        contentView.addSubview(bottomConnector)
    }
    
    func includeTopConnector() {
        let topConnector = UIView(frame: CGRect(x: timeBubble.frame.midX - 1, y: 0, width: 2, height: timeBubble.frame.minY - 4))
        topConnector.backgroundColor = Constants.postSeparatorColor
        contentView.addSubview(topConnector)
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
