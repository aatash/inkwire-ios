//
//  LoginViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var googleLoginButton: UIButton!
    var backgroundImageView: UIImageView!
    var hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let appColor = Constants.appColor
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        backgroundSetup()
        textFieldSetup(screenWidth: screenWidth, inkwireColor: appColor)
        buttonSetup(screenWidth: screenWidth, inkwireColor: appColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func backgroundSetup() {
        let gradientOverlay = UIImageView(frame: view.frame)
        gradientOverlay.image = UIImage(named: "gradientOverlay")
        view.insertSubview(gradientOverlay, at: 0)
        
        let backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "welcomeWallpaper")
        view.insertSubview(backgroundImage, at: 0)
    }
    
    func buttonSetup(screenWidth: CGFloat, inkwireColor: UIColor) {
        let loginButton = UIButton(frame: CGRect(x: 20, y: passwordTextField.frame.maxY + 20, width: UIScreen.main.bounds.width - 40, height: 50))
        loginButton.setTitle("Log In", for: .normal)
        loginButton.titleLabel!.font = UIFont(name: ".SF NS Text", size: 1)
        loginButton.layer.cornerRadius = 25
        loginButton.clipsToBounds = true
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 2
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        googleLoginButton = UIButton(frame: CGRect(x: 20, y: loginButton.frame.maxY + 8, width: UIScreen.main.bounds.width - 40, height: 50))
        googleLoginButton.setTitle("Login with Google", for: .normal)
        googleLoginButton.setTitleColor(UIColor.white, for: .normal)
        googleLoginButton.backgroundColor = UIColor(red: 225/255, green: 73/255, blue: 43/255, alpha: 1.0)
        googleLoginButton.layer.cornerRadius = 25
        googleLoginButton.layer.masksToBounds = true
        googleLoginButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        view.addSubview(googleLoginButton)
        
        let forgotPassButton = UIButton(frame: CGRect(x: 20, y: googleLoginButton.frame.maxY + 10, width: UIScreen.main.bounds.width - 40, height: 20))
        forgotPassButton.setTitle("Forgot password?", for: .normal)
        forgotPassButton.titleLabel!.font = UIFont(name: ".SF NS Text", size: 1)
        forgotPassButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        view.addSubview(forgotPassButton)
    }
    
    func googleSignIn() {
        hud?.textLabel.text = "Logging in..."
        hud?.show(in: view)
        GIDSignIn.sharedInstance().signIn()
    }
    
    func textFieldSetup(screenWidth: CGFloat, inkwireColor: UIColor) {
        let square = UIView(frame: CGRect(x: (screenWidth - UIScreen.main.bounds.width + 35)/2, y: 80, width: UIScreen.main.bounds.width - 30, height: 110))
        square.layer.backgroundColor = UIColor.white.cgColor
        square.alpha = 0.9
        square.layer.cornerRadius = 3
        square.clipsToBounds = true
        view.addSubview(square)
    
        emailTextField = UITextField(frame: CGRect(x: 20, y: 80, width: UIScreen.main.bounds.width - 40, height: 55))
        emailTextField.center.x = view.center.x
        emailTextField.placeholder = "EMAIL"
        emailTextField.font = UIFont(name: "SFUIText-Medium", size: 16)
        emailTextField.borderStyle = .none
        emailTextField.layer.cornerRadius = 3
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .default
        emailTextField.returnKeyType = .done
        emailTextField.delegate = self
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.contentVerticalAlignment = .center
        view.addSubview(emailTextField)
        var paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 45))
        emailTextField.leftView = paddingView
        emailTextField.leftViewMode = UITextFieldViewMode.always
        
        let emailIcon = UIImageView(frame: CGRect(x: emailTextField.frame.width - 35, y: (emailTextField.frame.height - 20)/2, width: 20, height: 20))
        emailIcon.contentMode = .scaleAspectFit
        emailIcon.image = UIImage(named: "emailIcon")
        emailTextField.addSubview(emailIcon)
        
        passwordTextField = UITextField(frame: CGRect(x: 20, y: emailTextField.frame.maxY, width: UIScreen.main.bounds.width - 40, height: 55))
        passwordTextField.center.x = view.center.x
        passwordTextField.placeholder = "PASSWORD"
        passwordTextField.font = UIFont(name: "SFUIText-Medium", size: 16)
        paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftView = paddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        
        let passwordIcon = UIImageView(frame: CGRect(x: passwordTextField.frame.width - 35, y: (passwordTextField.frame.height - 20)/2, width: 20, height: 20))
        passwordIcon.contentMode = .scaleAspectFit
        passwordIcon.image = UIImage(named: "passwordIcon")
        passwordTextField.addSubview(passwordIcon)
        
        let seperator = UIView(frame: CGRect(x: (screenWidth - UIScreen.main.bounds.width + 40)/2, y: emailTextField.frame.maxY, width: UIScreen.main.bounds.width - 40, height: 1))
        seperator.center.x = view.center.x
        seperator.backgroundColor = Constants.loginSeparatorColor
        view.addSubview(seperator)
    }
    
    func loginButtonTapped() {
        hud?.textLabel.text = "Logging in..."
        hud?.show(in: view)
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            self.hud?.dismiss()
            if error == nil {
                self.performSegue(withIdentifier: "toJournalsFromLogin", sender: self)
            } else {
                let alert = UIAlertController(title: "Invalid Entry", message: "Incorrect Email or Password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func forgotPassword() {
        var emailField = UITextField()
        let alert = UIAlertController(title: "Forgot Password", message: "Enter your email address and we'll send you an email to reset your password.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Email Address"
            emailField = textfield
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailField.text!, completion: { (error) in
                let alertTitle = error == nil ? "Success" : "Failed to Reset Password"
                let alertMessage = error == nil ? "Check your email to finish resetting your password." : "Please try again later."
                let finalAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                finalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(finalAlert, animated: true, completion: nil)
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(nextAction)
        present(alert, animated: true, completion: nil)
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
                self.performSegue(withIdentifier: "toJournalsFromLogin", sender: self)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func saveUsername(name: String) {
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("Users/\(currUserId!)/fullName").setValue(name)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: GIDSignInDelegate, GIDSignInUIDelegate
extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
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
                self.hud?.dismiss()
                dbRef.child("Users/\(user!.uid)/fullName").setValue(user?.displayName!)
                self.performSegue(withIdentifier: "toJournalsFromLogin", sender: self)
            } else {
                self.checkHasUsername(withBlock: { hasUsername -> Void in
                    if !hasUsername {
                        DispatchQueue.main.async {
                            self.hud?.dismiss()
                            self.requestUsername()
                        }
                    } else {
                        self.hud?.dismiss()
                        self.performSegue(withIdentifier: "toJournalsFromLogin", sender: self)
                    }
                })
            }
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        
    }
}

