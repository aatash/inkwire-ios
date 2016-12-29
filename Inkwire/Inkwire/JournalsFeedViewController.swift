//
//  JournalsFeedViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//
import UIKit
import ChameleonFramework
import JGProgressHUD
import ImagePicker
import Firebase
import BBBadgeBarButtonItem

class JournalsFeedViewController: UIViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    
    
    var journals = [Journal]()
    var numJournals = 0
    var collectionView: UICollectionView!
    var selectedJournal: Journal!
    var hud = JGProgressHUD(style: JGProgressHUDStyle.light)
    var selectedImageForJournal: UIImage?
    var negativeStateView: JournalsNegativeStateView!
    var menuButton: BBBadgeBarButtonItem!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.fixedHeightWhenStatusBarHidden = true
        tabBarController?.tabBar.tintColor = Constants.appColor
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = UIColor(hex: "#EEF2F5")
        
        setupCollectionView()
        setupNegativeStateView()
        
        hud?.textLabel.text = "Loading..."
        hud?.show(in: view)
        refresh()
    }
   
    func refresh() {
        var possibleJournalIds = [String]()
        
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        InkwireDBUtils.getUserOnce(withId: currUserId!, withBlock: { currUser -> Void in
            possibleJournalIds = currUser.journalIds!
            if possibleJournalIds.count == 0 {
                self.showNegativeStateView()
                self.hud?.dismiss()
                return
            }
            InkwireDBUtils.pollForJournals(withIds: possibleJournalIds, withBlock: { retrievedJournal -> Void in
                
                var indexPaths = [IndexPath]()
                if self.journals.index(where: {$0.journalId == retrievedJournal.journalId}) != nil {
                    return
                }
                let currUserId = FIRAuth.auth()?.currentUser?.uid
                if !(retrievedJournal.contributorIds?.contains(currUserId!))! {
                    _ = possibleJournalIds.remove(object: retrievedJournal.journalId!)
                    if possibleJournalIds.count == 0 {
                        self.showNegativeStateView()
                        self.hud?.dismiss()
                        return
                    }
                    return
                }
                
                self.journals.append(retrievedJournal)
                self.journals.sort(by: { (journalOne, journalTwo) -> Bool in
                    return journalOne.updatedAt! > journalTwo.updatedAt!
                })
                let index = self.journals.index(where: {$0.journalId == retrievedJournal.journalId})
                indexPaths.append(IndexPath(item: index!, section: 0))
                
                
                DispatchQueue.main.async {
                    if self.negativeStateView.superview != nil {
                        self.hideNegativeStateView()
                    }
                    self.collectionView.performBatchUpdates({ Void in
                        self.numJournals += 1
                        self.collectionView.insertItems(at: indexPaths)
                        self.hud?.dismiss()
                        }, completion: nil)
                }
            })
        })

    }
    
    func setupNegativeStateView() {
        negativeStateView = JournalsNegativeStateView(frame: view.frame)
        negativeStateView.delegate = self
    }
    
    func showNegativeStateView() {
        collectionView.isHidden = true
        view.addSubview(negativeStateView)
    }
    
    func hideNegativeStateView() {
        negativeStateView.removeFromSuperview()
        collectionView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        tabBarController?.tabBar.isHidden = false
        InkwireDBUtils.checkNumPendingInvites(withBlock: { numPending -> Void in
            if numPending > 0 {
                self.menuButton.badgeValue = String(numPending)
                self.menuButton.badgeOriginX = 17
                self.menuButton.badgeOriginY = -2
                self.menuButton.badgeBGColor = UIColor.red
            }
        })
        refresh()
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = Constants.appColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "newPostButton")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(toNewJournal))
        
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
        let titleImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 120, height: 21))
        titleImageView.image = UIImage(named: "inkwireTitle")
        titleImageView.contentMode = .scaleAspectFit
        titleImageView.clipsToBounds = true
        navigationItem.titleView = titleImageView
        navigationController?.navigationBar.layer.shadowColor = Constants.navBarShadowColor.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.5
        navigationController?.navigationBar.layer.shadowRadius = 2
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2, height: 2)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 10, bottom: 69, right: 10)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 10
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hex: "#EEF2F5")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(JournalCollectionViewCell.self, forCellWithReuseIdentifier: "journalCell")
        view.addSubview(collectionView)
    }
    
    func toNewJournal() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostsFromMyJournals" {
            let destVC = segue.destination as! PostsViewController
            destVC.journal = selectedJournal
            destVC.delegate = self
            UIApplication.shared.isStatusBarHidden = true
            navigationController?.isNavigationBarHidden = true
        } else if segue.identifier == "toNewJournal" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewJournalViewController
            destVC.journalImage = selectedImageForJournal
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension JournalsFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numJournals
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalCollectionViewCell
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        cell.awakeFromNib()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let journal = journals[indexPath.item]
        let cell = cell as! JournalCollectionViewCell
        journal.getCoverPic(withBlock: { retrievedImage -> Void in
            cell.imageView.image = retrievedImage
        })
        cell.contributorsLabel.text = "You and \(journal.contributorIds!.count - 1) others"
        cell.titleLabel.text = journal.title!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 30)/2, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedJournal = journals[indexPath.item]
        performSegue(withIdentifier: "toPostsFromMyJournals", sender: self)
    }
}

// MARK: - ImagePickerDelegate
extension JournalsFeedViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if images.count > 0 {
            selectedImageForJournal = images.first
            self.performSegue(withIdentifier: "toNewJournal", sender: self)
        }
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}

//MARK: - JournalsNegativeStateViewDelegate
extension JournalsFeedViewController: JournalsNegativeStateViewDelegate {
    func newJournalTapped() {
        toNewJournal()
    }
}

//MARK: - PostsViewControllerDelegate
extension JournalsFeedViewController: PostsViewControllerDelegate {
    func didDeleteJournal(withId: String) {
        DispatchQueue.main.async {
            let index = self.journals.index(where: {$0.journalId == withId})
            if index != nil {
                self.journals.remove(at: index!)
                self.numJournals -= 1
                self.collectionView.reloadData()
            }
        }
    }
}

