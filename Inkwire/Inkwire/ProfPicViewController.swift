//
//  ProfPicViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import UIKit
import ImagePicker
import Firebase
import JGProgressHUD
class ProfPicViewController: UIViewController {
    
    var profPicImageView: UIImageView!
    var choosePicButton: UIButton!
    var finishButton: UIButton!
    var hud = JGProgressHUD(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "welcomeWallpaper")
        view.addSubview(backgroundImage)

        let blackGradientOverlay = UIImageView(frame: view.frame)
        blackGradientOverlay.image = UIImage(named: "blackGradientOverlay")
        view.addSubview(blackGradientOverlay)
        
        profPicImageView = UIImageView(frame: CGRect(x: 0, y: 150, width: 180, height: 180))
        profPicImageView.center.x = view.center.x
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        profPicImageView.clipsToBounds = true
        profPicImageView.contentMode = .scaleAspectFill
        profPicImageView.image = UIImage(named: "profPicPlaceholder")
        view.addSubview(profPicImageView)
        
        choosePicButton = UIButton(frame: CGRect(x: 15, y: view.frame.height - 150, width: view.frame.width - 30, height: 45))
        choosePicButton.layer.cornerRadius = choosePicButton.frame.height/2
        choosePicButton.clipsToBounds = true
        choosePicButton.layer.borderColor = UIColor.white.cgColor
        choosePicButton.layer.borderWidth = 1.5
        choosePicButton.setTitleColor(UIColor.white, for: .normal)
        choosePicButton.setTitle("Choose Profile Picture", for: .normal)
        choosePicButton.backgroundColor = UIColor.clear
        choosePicButton.addTarget(self, action: #selector(choosePicButtonTapped), for: .touchUpInside)
        view.addSubview(choosePicButton)
        
        finishButton = UIButton(frame: CGRect(x: 15, y: choosePicButton.frame.maxY + 20, width: view.frame.width - 30, height: 45))
        finishButton.layer.cornerRadius = finishButton.frame.height/2
        finishButton.clipsToBounds = true
        finishButton.layer.borderColor = UIColor.white.cgColor
        finishButton.layer.borderWidth = 1.5
        finishButton.setTitleColor(UIColor.white, for: .normal)
        finishButton.setTitle("Finish", for: .normal)
        finishButton.backgroundColor = UIColor.clear
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        view.addSubview(finishButton)
    }
    
    func choosePicButtonTapped() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func finishButtonTapped() {
        hud.textLabel.text = "Saving..."
        hud.show(in: view)
        let currUserId = Auth.auth().currentUser?.uid
        InkwireDBUtils.uploadImage(image: profPicImageView.image!, withBlock: { downloadUrlString -> Void in
            Database.database().reference().child("Users/\(currUserId!)/profPicUrl").setValue(downloadUrlString, withCompletionBlock: { (error, ref) -> Void in
                if error == nil {
                    self.hud.dismiss()
                    self.performSegue(withIdentifier: "toJournalsFromProfPic", sender: self)
                } else {
                    print("An error occurred while saving the image url: \(String(describing: error))")
                }
            })
        })
    }
}

extension ProfPicViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if images.count > 0 {
            profPicImageView.image = images.first
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}

