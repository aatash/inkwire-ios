//
//  JournalsNegativeStateView.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/20/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

protocol JournalsNegativeStateViewDelegate {
    func newJournalTapped()
}

class JournalsNegativeStateView: UIView {

    var delegate: JournalsNegativeStateViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Constants.backgroundColor
        
        let bookIcon = UIImageView(frame: CGRect(x: (frame.width - 100)/2, y: 90, width: 100, height: 100))
        bookIcon.image = UIImage(named: "bookIcon")
        bookIcon.contentMode = .scaleAspectFit
        addSubview(bookIcon)
        
        let helpTextLabel = UILabel(frame: CGRect(x: 35, y: bookIcon.frame.maxY + 20, width: frame.width - 70, height: 75))
        helpTextLabel.font = UIFont(name: "SFUIText-Regular", size: 20)
        helpTextLabel.textColor = Constants.helpTextColor
        helpTextLabel.numberOfLines = 0
        helpTextLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1
        let text = "You don’t have any journals yet. Have your friends invite you to theirs or make your own!"
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        helpTextLabel.attributedText = attrString
        addSubview(helpTextLabel)
        
        let newJournalButton = UIButton(frame: CGRect(x: (frame.width - 200)/2, y: helpTextLabel.frame.maxY + 30, width: 200, height: 45))
        newJournalButton.layer.cornerRadius = newJournalButton.frame.height/2
        newJournalButton.clipsToBounds = true
        newJournalButton.backgroundColor = Constants.appColor
        newJournalButton.setTitleColor(UIColor.white, for: .normal)
        newJournalButton.setTitle("New Journal", for: .normal)
        newJournalButton.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 17)
        newJournalButton.addTarget(self, action: #selector(newJournalTapped), for: .touchUpInside)
        addSubview(newJournalButton)
    }
    
    func newJournalTapped() {
        delegate?.newJournalTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
