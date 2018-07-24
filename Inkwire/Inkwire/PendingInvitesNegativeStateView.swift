//
//  PendingInvitesNegativeStateView.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/21/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class PendingInvitesNegativeStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Constants.backgroundColor
        
        let icon = UIImageView(frame: CGRect(x: (frame.width - 100)/2, y: 90, width: 100, height: 100))
        icon.image = UIImage(named: "invites")
        icon.contentMode = .scaleAspectFit
        addSubview(icon)
        
        let helpTextLabel = UILabel(frame: CGRect(x: 35, y: icon.frame.maxY + 35, width: frame.width - 70, height: 75))
        helpTextLabel.font = UIFont(name: "SFUIText-Regular", size: 20)
        helpTextLabel.textColor = Constants.helpTextColor
        helpTextLabel.numberOfLines = 0
        helpTextLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1
        let text = "You don't have any pending invites. Ask your friends to invite you to their journals!"
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(kCTParagraphStyleAttributeName as NSAttributedStringKey, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        helpTextLabel.attributedText = attrString
        addSubview(helpTextLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
