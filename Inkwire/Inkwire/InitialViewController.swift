//
//  InitialViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /**
         If User is logged in, segue automatically to main screen.  Otherwise, display welcome screen.
         */
        FIRAuth.auth()?.addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "toMain", sender: self)
            } else {
                self.performSegue(withIdentifier: "toWelcome", sender: self)
            }
        }
        
        let gradientOverlay = UIImageView(frame: view.frame)
        gradientOverlay.image = UIImage(named: "gradientOverlay")
        view.insertSubview(gradientOverlay, at: 0)
        
        let backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "welcomeWallpaper")
        view.insertSubview(backgroundImage, at: 0)


    }
}
