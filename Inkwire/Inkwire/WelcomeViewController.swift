//
//  WelcomeViewController.swift
//  Inkwire
//
//  Created by Kevin Jiang on 11/16/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UINavigationControllerDelegate {
    
    var loginButton: UIButton!
    var signUpButton: UIButton!
    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    var screenBounds: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()

        screenBounds = UIScreen.main.bounds
        
        let blackGradientOverlay = UIImageView(frame: screenBounds)
        blackGradientOverlay.image = UIImage(named: "blackGradientOverlay")
        view.insertSubview(blackGradientOverlay, at: 0)
        
        let backgroundImage = UIImageView(frame: screenBounds)
        backgroundImage.image = UIImage(named: "welcomeWallpaper")
        view.insertSubview(backgroundImage, at: 0)
        
        setUpLoginButton()
        setUpSignUpButton()
        setUpPageControl()
        setUpScrollView()
    }
    
    func setupNavBar() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.isTranslucent = true
        navigationController!.view.backgroundColor = UIColor.clear
    }
    
    func pageTurn(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func setUpLoginButton() {
        loginButton = UIButton(frame: CGRect(x: 28, y: screenBounds.maxY - 70, width: screenBounds.width - 56, height: 50))
        loginButton.setTitle("Log in", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 25
        loginButton.layer.masksToBounds = true
        loginButton.addTarget(self, action: #selector(segueToLogin), for: .touchUpInside)
        view.addSubview(loginButton)
    }
    
    func setUpSignUpButton() {
        signUpButton = UIButton(frame: CGRect(x: 28, y: screenBounds.maxY - 140, width: screenBounds.width - 56, height: 50))
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.masksToBounds = true
        signUpButton.addTarget(self, action: #selector(segueToSignUp), for: .touchUpInside)
        view.addSubview(signUpButton)
    }
    
    func setUpPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: (view.frame.width - 200)/2, y: signUpButton.frame.minY - 50, width: 200, height: 50))
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageTurn), for: UIControlEvents.valueChanged)
        view.addSubview(pageControl)
    }
    
    func setUpScrollView() {
        let scrollViewHeight = pageControl.frame.minY - 100
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: scrollViewHeight) )
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width * 3, height: scrollViewHeight)
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        let iconView = UIView(frame: CGRect(x: scrollView.frame.minX, y: 0, width: view.frame.width, height: scrollView.frame.height))
        let iconImageView = UIImageView(frame: CGRect(x: (view.frame.width / 2) - 100, y: 0, width: 200, height: 100))
        iconImageView.image = UIImage(named: "iconwhite")
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)
        scrollView.addSubview(iconView)

        let collaborateViewFrame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
        let collaborateView = WelcomeScreenPage(frame: collaborateViewFrame, icon: (UIImage(named: "groupsIconBig")?.withRenderingMode(.alwaysTemplate))!, scrollViewTitle: "Collaboratively document your learning experiences")
        scrollView.addSubview(collaborateView)
        
        let followViewFrame = CGRect(x: 2*view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
        let followView = WelcomeScreenPage(frame: followViewFrame, icon: (UIImage(named: "likeIconBig")?.withRenderingMode(.alwaysTemplate))!, scrollViewTitle: "Like & comment on each other's work")
        scrollView.addSubview(followView)
        
    }
    
    func segueToLogin() {
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    func segueToSignUp() {
        performSegue(withIdentifier: "toSignup", sender: self)
    }
    
}

extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
