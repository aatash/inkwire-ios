//
//  SettingsViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker
import BBBadgeBarButtonItem
import JGProgressHUD



class SettingsViewController: UIViewController {
    
    var profilePic: UIImageView!
    var name: UILabel!
    var email: UILabel!
    var tableView: UITableView!
    let labelArray = ["Change E-mail", "Change Password", "Change Picture", "Logout"]
    let iconArray = [UIImage(named: "changeEmailButton"), UIImage(named: "passwordIcon"), UIImage(named: "changePictureButton"), UIImage(named: "logout")]
    var changedEmailTextField: UITextField!
    var changedPasswordTextField: UITextField!
    var menuButton: BBBadgeBarButtonItem!
    var hud = JGProgressHUD(style: .light)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.fixedHeightWhenStatusBarHidden = true
        view.backgroundColor = Constants.backgroundColor
        setupNavBar()
        setUpProfPic()
        setUpName()
        setUpEmail()
        setUpTableView()
        let currUserId = Auth.auth().currentUser?.uid
        InkwireDBUtils.getUser(withId: currUserId!, withBlock: { retrievedUser -> Void in
            self.email.text = retrievedUser.email!
            self.name.text = retrievedUser.name!
            retrievedUser.getProfPic(withBlock: { retrievedImage -> Void in
                self.profilePic.image = retrievedImage
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        InkwireDBUtils.checkNumPendingInvites(withBlock: { numPending -> Void in
            if numPending > 0 {
                self.menuButton.badgeValue = String(numPending)
                self.menuButton.badgeOriginX = 17
                self.menuButton.badgeOriginY = -2
                self.menuButton.badgeBGColor = UIColor.red
            }
        })
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = Constants.appColor
        navigationController?.navigationBar.tintColor = UIColor.white
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        customButton.setImage(UIImage(named: "hamburgerMenu"), for: .normal)
        
        if revealViewController() != nil {
            customButton.addTarget(revealViewController(), action: Selector(("revealToggle:")), for: .touchUpInside)
            
            revealViewController().rearViewRevealWidth = 200
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        menuButton = BBBadgeBarButtonItem(customUIButton: customButton)
        navigationItem.leftBarButtonItem = menuButton
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.title = "Settings"
        let titleDict: NSDictionary = [kCTForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        navigationController?.navigationBar.layer.shadowColor = Constants.navBarShadowColor.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.9
        navigationController?.navigationBar.layer.shadowRadius = 2
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2, height: 2)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setUpProfPic() {
        profilePic = UIImageView(frame: CGRect(x: (view.frame.width - 100)/2, y: 30, width: 100, height: 100))
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill

        view.addSubview(profilePic)
    }
    
    func setUpName() {
        name = UILabel(frame: CGRect(x: (view.frame.width - 200)/2, y: profilePic.frame.maxY + 15, width: 200, height: 18)) 
        name.textColor = UIColor.darkGray
        name.textAlignment = .center
        name.font = UIFont(name: "SFUIText-Medium", size: 16)
        view.addSubview(name)
    }
    
    func setUpEmail() {
        email = UILabel(frame: CGRect(x: (view.frame.width - 300)/2, y: 5 + name.frame.maxY, width: 300, height: 18))
        email.textColor = UIColor.lightGray
        email.textAlignment = .center
        email.font = UIFont(name: "SFUIText-Regular", size: 13)
        view.addSubview(email)
    }
    
    func setUpTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: email.frame.maxY + 30, width: view.frame.width, height: 48 * 4))
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "settingTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.isScrollEnabled = true
        tableView.isHidden = false
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
    }
    
    func changePictureTapped() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func changePasswordTapped() {
        let alertController = UIAlertController(title: "Change Password", message: "Please enter new password",preferredStyle: .alert)
        
        func newPasswordEntered(alert: UIAlertAction!){
            hud.textLabel.text = "Updating..."
            hud.show(in: view)
            
            Auth.auth().currentUser?.updatePassword(to: changedPasswordTextField.text!, completion: { error -> Void in
                if error != nil {
                    print("error while updating email: \(error)")
                    self.hud.dismiss()
                } else {
                    self.hud.dismiss()
                }
            })
        }
        
        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter new password"
            self.changedPasswordTextField = textField
        })
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: newPasswordEntered))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func changeEmailTapped() {
        let alertController = UIAlertController(title: "Change Email", message: "Please enter new Email",preferredStyle: .alert)
        
        func newEmailEntered(alert: UIAlertAction!){
            hud.textLabel.text = "Updating..."
            hud.show(in: view)
            let currUserId = Auth.auth().currentUser?.uid
            Auth.auth().currentUser?.updateEmail(to: changedEmailTextField.text!, completion: { error -> Void in
                if error != nil {
                    print("error while updating email: \(error)")
                    self.hud.dismiss()
                } else {
                    Database.database().reference().child("Users/\(currUserId!)/email").setValue(self.changedEmailTextField.text!, withCompletionBlock: { (error, ref) -> Void in
                        if error != nil {
                            self.email.text = self.changedEmailTextField.text!
                            self.hud.dismiss()
                        } else {
                            print("An error occurred while saving the image url: \(error)")
                            self.hud.dismiss()
                        }
                    })
                }
            })
           }
        
        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter new E-mail"
            self.changedEmailTextField = textField
        })
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: newEmailEntered))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func logoutTapped() {
        try! Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath)
            as! SettingTableViewCell
        
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        
        cell.awakeFromNib()
        
        if indexPath.item == 3 {
            cell.actionName.textColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let settingCell = cell as! SettingTableViewCell
        settingCell.icon.image = iconArray[indexPath.row]?.withRenderingMode(.alwaysTemplate)
        settingCell.actionName.text = labelArray[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            changeEmailTapped()
        } else if indexPath.item == 1 {
            changePasswordTapped()
        } else if indexPath.row == 2 {
            changePictureTapped()
        } else if indexPath.row == 3 {
            logoutTapped()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
}

extension SettingsViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if images.count > 0 {
            uploadChangedPicture(changedImage: images.first!)
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    func uploadChangedPicture(changedImage: UIImage) {
        hud.textLabel.text = "Saving..."
        hud.show(in: view)
        let currUserId = Auth.auth().currentUser?.uid
        InkwireDBUtils.uploadImage(image: changedImage, withBlock: { downloadUrlString -> Void in
            Database.database().reference().child("Users/\(currUserId!)/profPicUrl").setValue(downloadUrlString, withCompletionBlock: { (error, ref) -> Void in
                if error == nil {
                    self.profilePic.image = changedImage
                    self.hud.dismiss()
                    print("picture change success")
                } else {
                    print("An error occurred while saving the image url: \(error)")
                    self.hud.dismiss()
                }
            })
        })
    }
}
