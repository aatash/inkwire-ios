//
//  SignupViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
class SignupViewController: UIViewController, UINavigationControllerDelegate, GIDSignInUIDelegate {
    
    var ref: FIRDatabaseReference!
    var screenBounds: CGRect!
    var signUpButton: UIButton!
    var googleButton: UIButton!
    var needLogin: UIButton!
    var emailTextField: UITextField!
    var passTextField: UITextField!
    var nameTextField: UITextField!
    var paddingView: UIView!
    var hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        screenBounds = UIScreen.main.bounds
        
        let gradientOverlay = UIImageView(frame: screenBounds)
        gradientOverlay.image = UIImage(named: "gradientOverlay")
        view.insertSubview(gradientOverlay, at: 0)
        
        let backgroundImage = UIImageView(frame: screenBounds)
        backgroundImage.image = UIImage(named: "welcomeWallpaper")
        view.insertSubview(backgroundImage, at: 0)
        
        ref = FIRDatabase.database().reference()
        
        setUpSignUpButton()
        setUpGoogleButton()
        setUpNeedLogin()
        setUpTextFields()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func setUpSignUpButton() {
        signUpButton = UIButton(frame: CGRect(x: 15, y: 262, width: screenBounds.width - 30, height: 50))
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.masksToBounds = true
        signUpButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        view.addSubview(signUpButton)
    }
    
    func setUpGoogleButton() {
        googleButton = UIButton(frame: CGRect(x: 15, y: signUpButton.frame.maxY + 10, width: screenBounds.width - 30, height: 50))
        googleButton.setTitle("Signup with Google", for: .normal)
        googleButton.setTitleColor(UIColor.white, for: .normal)
        googleButton.backgroundColor = UIColor(red: 225/255, green: 73/255, blue: 43/255, alpha: 1.0)
        googleButton.layer.cornerRadius = 25
        googleButton.layer.masksToBounds = true
        googleButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        view.addSubview(googleButton)
    }
    
    func googleSignIn() {
        hud?.textLabel.text = "Signing up..."
        hud?.show(in: view)
        GIDSignIn.sharedInstance().signIn()
    }
    
    func setUpNeedLogin() {
        needLogin = UIButton(frame: CGRect(x: (view.frame.width - 240)/2, y: googleButton.frame.maxY + 10, width: 240, height: 18))
        let needLoginString = "Already have an account? Sign in"
        let myAttribute = [ NSForegroundColorAttributeName: UIColor.white ]
        let needLoginAttrString = NSAttributedString(string: needLoginString, attributes: myAttribute)
        needLogin.setAttributedTitle(needLoginAttrString, for: .normal)
        needLogin.titleLabel!.font = UIFont(name: "SFUIText-Light", size: 15)
        needLogin.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        view.addSubview(needLogin)
    }
    
    func signInTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setUpTextFields() {
        let whiteBox = UIView(frame: CGRect(x: 15, y: 85, width: screenBounds.width - 30, height: 161))
        whiteBox.layer.backgroundColor = UIColor.white.cgColor
        whiteBox.alpha = 0.9
        whiteBox.layer.cornerRadius = 3
        whiteBox.clipsToBounds = true
        view.addSubview(whiteBox)
        
        emailTextField = UITextField(frame: CGRect(x: 15, y: 85, width: screenBounds.width - 30, height: 53.66))
        emailTextField.placeholder = "EMAIL"
        emailTextField.font = UIFont(name: "SFUIText-Medium", size: 16)
        paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftView = paddingView
        emailTextField.leftViewMode = UITextFieldViewMode.always
        emailTextField.layer.cornerRadius = 3
        emailTextField.autocorrectionType = .no
        emailTextField.delegate = self
        
        let emailIcon = UIImageView(frame: CGRect(x: emailTextField.frame.width - 35, y: (emailTextField.frame.height - 20)/2, width: 20, height: 20))
        emailIcon.contentMode = .scaleAspectFit
        emailIcon.image = UIImage(named: "emailIcon")
        emailTextField.addSubview(emailIcon)
        
        
        let divider1 = UIView(frame: CGRect(x: (screenBounds.width - whiteBox.frame.width + 20)/2, y: emailTextField.frame.minY + emailTextField.frame.height, width: whiteBox.frame.width - 20, height: 1))
        divider1.center.x = view.center.x
        divider1.backgroundColor = Constants.loginSeparatorColor
        view.addSubview(divider1)
        
        passTextField = UITextField(frame: CGRect(x: 15, y: emailTextField.frame.minY + 53.66, width: screenBounds.width - 30, height: 53.66))
        passTextField.placeholder = "PASSWORD"
        passTextField.font = UIFont(name: "SFUIText-Medium", size: 16)
        paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passTextField.frame.height))
        passTextField.leftView = paddingView
        passTextField.leftViewMode = UITextFieldViewMode.always
        passTextField.isSecureTextEntry = true
        passTextField.delegate = self
        
        let passwordIcon = UIImageView(frame: CGRect(x: passTextField.frame.width - 35, y: (passTextField.frame.height - 20)/2, width: 20, height: 20))
        passwordIcon.contentMode = .scaleAspectFit
        passwordIcon.image = UIImage(named: "passwordIcon")
        passTextField.addSubview(passwordIcon)
        
        let divider2 = UIView(frame: CGRect(x: (screenBounds.width - whiteBox.frame.width + 20)/2, y: emailTextField.frame.minY + emailTextField.frame.height + emailTextField.frame.height, width: whiteBox.frame.width - 20, height: 1))
        divider2.backgroundColor = Constants.loginSeparatorColor
        divider2.center.x = view.center.x
        view.addSubview(divider2)
        
        nameTextField = UITextField(frame: CGRect(x: 15, y: emailTextField.frame.minY + 53.66 + 53.66, width: screenBounds.width - 30, height: 53.66))
        nameTextField.placeholder = "FULL NAME"
        nameTextField.font = UIFont(name: "SFUIText-Medium", size: 16)
        paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = UITextFieldViewMode.always
        nameTextField.delegate = self
        
        let nameIcon = UIImageView(frame: CGRect(x: nameTextField.frame.width - 35, y: (nameTextField.frame.height - 20)/2, width: 20, height: 20))
        nameIcon.contentMode = .scaleAspectFit
        nameIcon.image = UIImage(named: "name")
        nameTextField.addSubview(nameIcon)
        
        view.addSubview(emailTextField)
        view.addSubview(passTextField)
        view.addSubview(nameTextField)
    }
    
    func signupButtonTapped() {
        hud?.textLabel.text = "Signing up..."
        hud?.show(in: view)
        FIRAuth.auth()!.createUser(withEmail: emailTextField.text!, password: passTextField.text!, completion: { user, error in
            self.hud?.dismiss()
            if error == nil {
                self.ref.child("Users/\(user!.uid)/email").setValue(self.emailTextField.text!)
                self.ref.child("Users/\(user!.uid)/fullName").setValue(self.nameTextField.text!)
                self.ref.child("Users/\(user!.uid)/profPicUrl").setValue(user?.photoURL)
                self.performSegue(withIdentifier: "toProfPic", sender: self)
            } else {
                let alert = UIAlertController(title: "", message: error!.localizedDescription, preferredStyle: .alert)
                let okay = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                })
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    func checkHasUsername(withBlock: @escaping (Bool) -> Void) {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("Users/\(currUserId!)").observe(.value, with: { snapshot -> Void in
            if snapshot.exists() {
                if let userDict = snapshot.value as? [String: Any] {
                    if userDict["fullName"] == nil {
                        withBlock(false)
                    } else {
                        withBlock(true)
                    }
                }
            }
        })
    }
    
    func requestUsername() {
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Enter Name", message: "Please enter your full name to continue.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Full Name"
            inputTextField = textField
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) -> Void in
            if inputTextField?.text == nil || inputTextField?.text == "" || inputTextField?.text == "Full Name" {
                self.requestUsername()
            } else {
                self.saveUsername(name: (inputTextField?.text)!)
                self.performSegue(withIdentifier: "toProfPic", sender: self)
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveUsername(name: String) {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("Users/\(currUserId!)/fullName").setValue(name)
    }

    
}

extension SignupViewController: UITextFieldDelegate {
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignupViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.hud?.dismiss()
            print("error while signing in with google: \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                self.hud?.dismiss()
                print("error while signing in with google: \(error)")
                return
            }
            let dbRef = FIRDatabase.database().reference()
            dbRef.child("Users/\(user!.uid)/email").setValue(user?.email!)
            
            
            if user?.photoURL != nil {
                dbRef.child("Users/\(user!.uid)/profPicUrl").setValue(user?.photoURL?.absoluteString)
            }
            
            if user?.displayName != nil {
                dbRef.child("Users/\(user!.uid)/fullName").setValue(user?.displayName!)
                self.hud?.dismiss()
                self.performSegue(withIdentifier: "toProfPic", sender: self)
            } else {
                self.checkHasUsername(withBlock: { hasUsername -> Void in
                    if !hasUsername {
                        DispatchQueue.main.async {
                            self.hud?.dismiss()
                            self.requestUsername()
                        }
                    } else {
                        self.hud?.dismiss()
                        self.performSegue(withIdentifier: "toProfPic", sender: self)
                    }
                })
            }
            
            
            
        }
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
    }
}
