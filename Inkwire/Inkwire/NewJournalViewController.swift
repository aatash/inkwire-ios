//
//  NewExperieinceViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/6/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit
import ImagePicker

class NewJournalViewController: UIViewController, UINavigationControllerDelegate {
    
    var selectedImageView: UIImageView!
    var blackGradientOverlay: UIImageView!
    var journalNameTextField: UITextField!
    var journalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        selectedImageView = UIImageView(frame: view.frame)
        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.image = journalImage
        view.addSubview(selectedImageView)
        
        blackGradientOverlay = UIImageView(frame: view.frame)
        blackGradientOverlay.contentMode = .scaleToFill
        blackGradientOverlay.image = UIImage(named: "blackgradient")
        view.addSubview(blackGradientOverlay)
        
        journalNameTextField = UITextField(frame: CGRect(x: 20, y: view.frame.height/2, width: view.frame.width - 40, height: 60))
        journalNameTextField.borderStyle = .none
        journalNameTextField.backgroundColor = UIColor.clear
        journalNameTextField.textColor = UIColor.white
        journalNameTextField.font = UIFont(name: "SFUIText-Regular", size: 25)
        journalNameTextField.delegate = self
        journalNameTextField.returnKeyType = .next
        let nameAttrStr = NSAttributedString(string: "Name this journal...", attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor(hex: "#DDDDDD")])
        journalNameTextField.attributedPlaceholder = nameAttrStr
        view.addSubview(journalNameTextField)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        beganKeyboardNotifications()
        journalNameTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        endKeyboardNotifications()
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.appColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "x")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.title = "New Journal"
        let titleDict: NSDictionary = [kCTForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewJournalDescription" {
            let destVC = segue.destination as! NewJournalDescriptionViewController
            destVC.journalImage = journalImage
            destVC.journalName = journalNameTextField.text
        }
    }
}

// MARK: - UITextFieldDelegate
extension NewJournalViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func beganKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func endKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                blackGradientOverlay.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardSize.height)
                journalNameTextField.frame.origin.y = view.frame.height - keyboardSize.height - 60 - 20
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "Name this journal..." || textField.text == "" || textField.text == nil {
            return false
        }
        performSegue(withIdentifier: "toNewJournalDescription", sender: self)
        return true
    }
}
