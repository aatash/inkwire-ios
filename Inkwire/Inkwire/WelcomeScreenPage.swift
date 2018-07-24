//
//  WelcomeScreenPage.swift
//  Inkwire
//
//  Created by Kevin Jiang on 11/19/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//
import UIKit

class WelcomeScreenPage: UIView {
    
    var iconImageView: UIImageView!
    var title: UILabel!
    
    init(frame: CGRect, icon: UIImage, scrollViewTitle: String) {
        super.init(frame: frame)
        
        title = UILabel(frame: CGRect(x: 28, y: 4, width: self.frame.width - 56, height: 64))
        title.text = scrollViewTitle
        title.textColor = UIColor.white
        title.font = UIFont(name: "Helvetica-Light", size: 27)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        addSubview(title)
        
        if UIScreen.main.bounds.width <= 320 {
            iconImageView = UIImageView(frame: CGRect(x: (self.frame.width - 100)/2, y: title.frame.maxY + 100, width: 100, height:  100))
        } else {
            iconImageView = UIImageView(frame: CGRect(x: (self.frame.width - 130.16)/2, y: title.frame.maxY + 100, width: 130.16, height:  130.16))
        }
        
        iconImageView.image = icon
        iconImageView.tintColor = UIColor.white
        iconImageView.contentMode = .scaleAspectFill
        addSubview(iconImageView)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
