//
//  CellSizeCalculator.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/28/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit

struct PostCellSizeAttributes {
    var contentLabelHeight: CGFloat?
    var cellContainerHeight: CGFloat?
}

struct JournalCellSizeAttributes {
    var descriptionLabelHeight: CGFloat?
    var cellHeight: CGFloat?
}

struct PostDetailCellSizeAttributes {
    var contentLabelHeight: CGFloat?
    var cellContainerHeight: CGFloat?
}

struct CommentCellSizeAttributes {
    var contentLabelHeight: CGFloat?
    var cellHeight: CGFloat?
}

class CellSizeCalculator {
    
    /**
     Calculates the size of a cell containing a post.
     
     - parameter withPost: the post whose cell size will be calculated
     
     */
    static func sizeForPostCell(withPost: Post) -> PostCellSizeAttributes {
        let contentLabelWidth = UIScreen.main.bounds.width - PostCellSettings.leftMargin - PostCellSettings.rightMargin
        let tempLabel = UILabel(frame: CGRect(x: PostCellSettings.leftMargin, y: 0, width: contentLabelWidth, height: 1000))
        tempLabel.text = withPost.content!
        tempLabel.numberOfLines = 0
        tempLabel.font = PostCellSettings.contentLabelFont
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.sizeToFit()
        var containerHeight: CGFloat = 20
        
        if withPost.imageUrl == nil {
            containerHeight += tempLabel.frame.height
        } else if withPost.imageUrl != nil && withPost.content != nil {
            containerHeight += tempLabel.frame.height + PostCellSettings.imageViewHeight
        } else {
            containerHeight += PostCellSettings.imageViewHeight
        }
        
        return PostCellSizeAttributes(contentLabelHeight: tempLabel.frame.height, cellContainerHeight: containerHeight)
    }
    
    /**
     Calculates the size of the cell containing the header.
     
     - parameter withJournal: the journal whose journal description will be used to calculate size
     
     */
    static func sizeForHeaderCell(withJournal: Journal) -> JournalCellSizeAttributes {
        let contentLabelWidth = UIScreen.main.bounds.width - HeaderCellSettings.leftMargin - HeaderCellSettings.rightMargin
        let tempLabel = UILabel(frame: CGRect(x: HeaderCellSettings.leftMargin, y: 0, width: contentLabelWidth, height: 1000))
        tempLabel.font = HeaderCellSettings.contentLabelFont
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 3
        let attrString = NSMutableAttributedString(string: (withJournal.description!))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        tempLabel.attributedText = attrString
        tempLabel.sizeToFit()
        
        return JournalCellSizeAttributes(descriptionLabelHeight: tempLabel.frame.height, cellHeight: tempLabel.frame.height + 50)
    }
    
    /**
     Calculates the size of a cell containing a comment.
     
     - parameter withComment: the comment whose cell size will be calculated
     
     */
    static func sizeForCommentCell(withComment: Comment) -> CommentCellSizeAttributes {
        let contentLabelWidth = UIScreen.main.bounds.width - CommentCellSettings.leftMargin - CommentCellSettings.rightMargin
        let tempLabel = UILabel(frame: CGRect(x: CommentCellSettings.leftMargin, y: 0, width: contentLabelWidth, height: 1000))
        tempLabel.text = withComment.content!
        tempLabel.font = CommentCellSettings.contentLabelFont
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.sizeToFit()
        
        return CommentCellSizeAttributes(contentLabelHeight: tempLabel.frame.height, cellHeight: tempLabel.frame.height + 50)
    }
    
    /**
     Calculates the size of a cell containing the details of a post.
     
     - parameter withPost: the post whose cell size will be calculated
     
     */
    static func sizeForDetailCell(withPost: Post) -> PostDetailCellSizeAttributes {
        let contentLabelWidth = UIScreen.main.bounds.width - PostDetailCellSettings.leftMargin - PostDetailCellSettings.rightMargin
        let tempLabel = UILabel(frame: CGRect(x: PostDetailCellSettings.leftMargin, y: 0, width: contentLabelWidth, height: 1000))
        tempLabel.text = withPost.content!
        tempLabel.numberOfLines = 0
        tempLabel.font = PostDetailCellSettings.contentLabelFont
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.sizeToFit()
        var containerHeight: CGFloat = 30
        
        if withPost.imageUrl == nil {
            containerHeight += tempLabel.frame.height
        } else if withPost.imageUrl != nil && withPost.content != nil {
            containerHeight += tempLabel.frame.height + PostDetailCellSettings.imageViewHeight
        } else {
            containerHeight += PostDetailCellSettings.imageViewHeight
        }
        
        return PostDetailCellSizeAttributes(contentLabelHeight: tempLabel.frame.height, cellContainerHeight: containerHeight)
    }
}
