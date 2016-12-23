//
//  NewPostViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import ImagePicker
import Firebase
import JGProgressHUD
class NewPostViewController: UIViewController {
    
    var profPicImageView: UIImageView!
    var imageView: UIImageView!
    var textView: UITextView!
    var postButton: UIBarButtonItem!
    let placeholderText = "Make a post to this experience..."
    var hud = JGProgressHUD(style: .light)
    var journal: Journal?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        profPicImageView = UIImageView(frame: CGRect(x: 18, y: 20, width: 45, height: 45))
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        profPicImageView.clipsToBounds = true
        profPicImageView.contentMode = .scaleAspectFill
        view.addSubview(profPicImageView)
        
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        InkwireDBUtils.getUser(withId: currUserId!, withBlock: { retrievedUser -> Void in
                        
            retrievedUser.getProfPic(withBlock: { retrievedImage -> Void in
                self.profPicImageView.image = retrievedImage
            })
        
        })
        
        textView = UITextView(frame: CGRect(x: profPicImageView.frame.maxX + 5, y: profPicImageView.frame.minY, width: view.frame.width - profPicImageView.frame.maxX - 5 - 10, height: 40))
        textView.textColor = UIColor.lightGray
        textView.backgroundColor = UIColor.white
        textView.font = UIFont(name: "SFUIText-Regular", size: 14.5)
        textView.text = placeholderText
        textView.layer.cornerRadius = 5
        textView.delegate = self
        view.addSubview(textView)
        
        imageView = UIImageView(frame: CGRect(x: 20, y: textView.frame.maxY + 20, width: view.frame.width - 40, height: 300))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        setupToolBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
        let startPosition = textView.beginningOfDocument
        textView.selectedTextRange = textView.textRange(from: startPosition, to: startPosition)
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.appColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "x")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.title = "New Post"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
    }
    
    func setupToolBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = UIColor.white
        toolBar.tintColor = UIColor.blue
        postButton = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.done, target: self, action: #selector(sendPost))
        postButton.isEnabled = false
        postButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray,
                                           NSFontAttributeName: UIFont(name: "SFUIText-Regular", size: 16)!], for: .disabled)
        postButton.setTitleTextAttributes([NSForegroundColorAttributeName: Constants.likeColor,
                                           NSFontAttributeName: UIFont(name: "SFUIText-Regular", size: 16)!], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let cameraButton = UIBarButtonItem(image: UIImage(named: "toolbarCamera")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(cameraButtonTapped))
        cameraButton.tintColor = UIColor.lightGray
        
        toolBar.setItems([cameraButton, spaceButton, postButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textView.inputAccessoryView = toolBar
    }
    
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func sendPost() {
        hud?.textLabel.text = "Posting..."
        hud?.show(in: view)
        journal?.addNewPost(content: textView.text, image: imageView.image, withBlock: { savedPost -> Void in
            self.hud?.dismiss()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func cameraButtonTapped() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: UITextViewDelegate, UITextFieldDelegate
extension NewPostViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView){
        textView.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.hasSuffix(placeholderText) && textView.text.characters.count == placeholderText.characters.count + 1 {
            var currText = textView.text
            if let range = currText?.range(of: placeholderText) {
                currText?.removeSubrange(range)
            }
            textView.text = currText
            textView.textColor = .black
        }
        
        if textView.text != placeholderText {
            textView.textColor = .black
        }
        
        if textView.text != "" && textView.text != placeholderText {
            postButton.isEnabled = true
        } else if (textView.text == "" || textView.text == placeholderText) && imageView.image == nil {
            postButton.isEnabled = false
        }
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        imageView.frame.origin.y = textView.frame.maxY + 20
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.endEditing(true)
    }
}

// MARK: - ImagePickerDelegate
extension NewPostViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if images.count > 0 {
            imageView.image = images.first
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}
