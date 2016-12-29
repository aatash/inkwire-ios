//
//  NewJournalDescriptionViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 12/19/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
class NewJournalDescriptionViewController: UIViewController, UINavigationControllerDelegate {
    
    var journalImage: UIImage?
    var journalName: String?
    var textView: UITextView!
    let placeholderText = "Describe what this journal is about..."
    var hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        textView = UITextView(frame: CGRect(x: 20, y: 20, width: view.frame.width - 40, height: 40))
        textView.textColor = UIColor.lightGray
        textView.backgroundColor = UIColor.white
        textView.font = UIFont(name: "SFUIText-Regular", size: 14.5)
        textView.text = placeholderText
        textView.layer.cornerRadius = 5
        textView.delegate = self
        textView.returnKeyType = .done
        view.addSubview(textView)
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backarrow")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.title = "New Journal"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate, UITextFieldDelegate
extension NewJournalDescriptionViewController: UITextViewDelegate, UITextFieldDelegate {
    
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
            textView.textColor = UIColor.black
        }
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text == "" || textView.text == placeholderText {
                return false
            } else {
                hud?.textLabel.text = "Saving..."
                hud?.show(in: view)
                let newJournal = Journal(title: journalName!, description: textView.text, coverPic: journalImage!)
                newJournal.saveToDB(withBlock: { savedJournal -> Void in
                    let currUserId = FIRAuth.auth()?.currentUser?.uid
                    InkwireDBUtils.getUserOnce(withId: currUserId!, withBlock: { currUser -> Void in
                        currUser.journalIds?.append(savedJournal.journalId!)
                        currUser.saveToDB(withBlock: { savedUser -> Void in
                            DispatchQueue.main.async {
                                self.hud?.dismiss()
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    })
                })
                return false
            }
        }
        return true
    }
}

