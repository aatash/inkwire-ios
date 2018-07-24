//
//  InitialViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /**
         If User is logged in, segue automatically to main screen.  Otherwise, display welcome screen.
         */
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "toMain", sender: self)
            } else {
                self.performSegue(withIdentifier: "toWelcome", sender: self)
            }
        }
        
        let blackGradientOverlay = UIImageView(frame: view.frame)
        blackGradientOverlay.image = UIImage(named: "blackGradientOverlay")
        view.insertSubview(blackGradientOverlay, at: 0)
        
        let backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "welcomeWallpaper")
        view.insertSubview(backgroundImage, at: 0)


    }
}
