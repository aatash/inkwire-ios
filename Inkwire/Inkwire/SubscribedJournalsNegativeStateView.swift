//
//  SubscribedJournalsNegativeStateView.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

class SubscribedJournalsNegativeStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Constants.backgroundColor
        
        let bookIcon = UIImageView(frame: CGRect(x: (frame.width - 100)/2, y: 90, width: 100, height: 100))
        bookIcon.image = UIImage(named: "bookIcon")
        bookIcon.contentMode = .scaleAspectFit
        addSubview(bookIcon)
        
        let helpTextLabel = UILabel(frame: CGRect(x: 35, y: bookIcon.frame.maxY + 35, width: frame.width - 70, height: 75))
        helpTextLabel.font = UIFont(name: "SFUIText-Regular", size: 20)
        helpTextLabel.textColor = Constants.helpTextColor
        helpTextLabel.numberOfLines = 0
        helpTextLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1
        let text = "You aren't subscribed to any journals yet. Ask your friends to invite you to their journals!"
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        helpTextLabel.attributedText = attrString
        addSubview(helpTextLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
