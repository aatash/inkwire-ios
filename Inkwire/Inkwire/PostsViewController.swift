//
//  PostsViewController.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import MXParallaxHeader
import Firebase
import JGProgressHUD


protocol PostsViewControllerDelegate {
    func didDeleteJournal(withId: String)
}

class PostsViewController: UIViewController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    var journal: Journal?
    var posts = [Post]()
    var collectionView: UICollectionView!
    var numPosts = 0
    var selectedPost: Post?
    var modalView: AKModalView!
    var hud = JGProgressHUD(style: .light)
    var delegate: PostsViewControllerDelegate? = nil
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        
        setupCollectionView()
        setupHeader()
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        if (journal?.contributorIds?.contains(currUserId!))! {
            setupNewPostButton()
        }

        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupNewPostButton() {
        let newPostButton = UIButton(frame: CGRect(x: view.frame.width - 85, y: view.frame.height - 85, width: 60, height: 60))
        newPostButton.clipsToBounds = false
        newPostButton.setImage(UIImage(named: "newPostButtonFull"), for: .normal)
        newPostButton.addTarget(self, action: #selector(newPostButtonTapped), for: .touchUpInside)
        view.insertSubview(newPostButton, aboveSubview: collectionView)
    }
    
    func refresh() {
        posts = [Post]()
        numPosts = 0
        collectionView.reloadData()
        journal?.pollForPosts(withBlock: { retrievedPost -> Void in
            var indexPaths = [IndexPath]()
            if self.posts.index(where: {$0.postId == retrievedPost.postId}) != nil || retrievedPost.date == nil{
                return
            }
            self.posts.append(retrievedPost)
            self.posts.sort(by: { (postOne, postTwo) -> Bool in
                return postOne.date! > postTwo.date!
            })
            let index = self.posts.index(where: {$0.postId == retrievedPost.postId})
            indexPaths.append(IndexPath(item: index!, section: 1))
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({ Void in
                    self.collectionView.insertItems(at: indexPaths)
                    self.numPosts += indexPaths.count
                    }, completion: nil)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        refresh()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(ImageTextPostCollectionViewCell.self, forCellWithReuseIdentifier: "imageTextCell")
        collectionView.register(TextPostCollectionViewCell.self, forCellWithReuseIdentifier: "textCell")
        collectionView.register(ImagePostCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.register(JournalHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "headerCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
    }
    
    func setupHeader() {
        
        
        let headerView: UIImageView = UIImageView()
        
        journal?.getCoverPic(withBlock: { retrievedImage -> Void in
            headerView.image = retrievedImage
        })
        
        headerView.contentMode = .scaleAspectFill
        collectionView.parallaxHeader.view = headerView
        collectionView.parallaxHeader.height = 300
        collectionView.parallaxHeader.mode = MXParallaxHeaderMode.fill
        collectionView.parallaxHeader.minimumHeight = 0
        
        
        let darkFilter = UIImageView(frame: CGRect(x: 0, y: -300, width: view.frame.width, height: 300))
        darkFilter.image = UIImage(named: "blackgradient")
        darkFilter.contentMode = .scaleToFill
        
        collectionView.addSubview(darkFilter)
        collectionView.bringSubview(toFront: darkFilter)
        view.bringSubview(toFront: darkFilter)
        
        let journalNameLabel = UILabel()
        journalNameLabel.font = UIFont(name: "SFUIText-Regular", size: 25)
        journalNameLabel.textColor = UIColor.white
        journalNameLabel.text = journal?.title!
        let sizeThatFits = journalNameLabel.sizeThatFits(CGSize(width: view.frame.width - 90, height: 1000))
        journalNameLabel.frame = CGRect(x: 20, y: darkFilter.frame.height - sizeThatFits.height - 20, width: view.frame.width - 90, height: sizeThatFits.height)
        darkFilter.addSubview(journalNameLabel)
     
        let backButton = UIButton(frame: CGRect(x: 15, y: 15, width: 35, height: 35))
        backButton.setImage(UIImage(named: "backarrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = UIColor.white
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backButton.layer.cornerRadius = backButton.frame.width/2
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        let inviteButton = UIButton(frame: CGRect(x: view.frame.width - 15 - 35, y: 15, width: 35, height: 35))
        inviteButton.setImage(UIImage(named: "inviteIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        inviteButton.tintColor = UIColor.white
        inviteButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        inviteButton.layer.cornerRadius = backButton.frame.width/2
        inviteButton.clipsToBounds = true
        inviteButton.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        view.addSubview(inviteButton)
        
        let deleteButton = UIButton(frame: CGRect(x: view.frame.width - 15 - 35 - 15 - 35, y: 15, width: 35, height: 35))
        deleteButton.setImage(UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.tintColor = UIColor.white
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        deleteButton.layer.cornerRadius = backButton.frame.width/2
        deleteButton.clipsToBounds = true
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        view.addSubview(deleteButton)
        
    }
    
    func deleteButtonTapped() {
        hud?.textLabel.text = "Deleting..."
        hud?.show(in: view)
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        InkwireDBUtils.getUserOnce(withId: currUserId!, withBlock: { currUser -> Void in
            if !(currUser.journalIds?.contains((self.journal?.journalId)!))! {
                return
            }
            currUser.journalIds?.remove(object: (self.journal?.journalId)!)
            currUser.saveToDB(withBlock: { savedUser -> Void in
                DispatchQueue.main.async {
                    self.hud?.dismiss()
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didDeleteJournal(withId: (self.journal?.journalId)!)
                }
            })
        })
    }
    
    func inviteButtonTapped() {
        let inviteView = InviteView(frame: CGRect(x: 30, y: 30, width: view.frame.width - 60, height: 350))
        inviteView.delegate = self
        modalView = AKModalView(view: inviteView)
        modalView.automaticallyCenter = false
        view.addSubview(modalView)
        modalView.show()
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetail" {
            let destVC = segue.destination as! PostDetailViewController
            destVC.post = selectedPost
        } else if segue.identifier == "toNewPost" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewPostViewController
            destVC.journal = journal
        }
    }
    
    func newPostButtonTapped() {
        performSegue(withIdentifier: "toNewPost", sender: self)
    }
    
}

extension PostsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return numPosts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! JournalHeaderCollectionViewCell
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            cell.awakeFromNib()
            let attr = CellSizeCalculator.sizeForHeaderCell(withJournal: journal!)
            cell.setupCell(withAttr: attr)
            
            return cell
        }
        
        var cell: PostCollectionViewCell!
        let post = posts[indexPath.item]
        let cellSizeAttr = CellSizeCalculator.sizeForPostCell(withPost: post)
        if post.imageUrl == nil {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextPostCollectionViewCell
        } else if post.imageUrl != nil && post.content != nil {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTextCell", for: indexPath) as! ImageTextPostCollectionViewCell

        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageTextCell", for: indexPath) as! ImagePostCollectionViewCell
        }
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        cell.awakeFromNib()
        cell.delegate = self
        cell.setupCell(withAttr: cellSizeAttr)
        if indexPath.item != 0 {
            cell.includeTopConnector()
        }
        
        if indexPath.item != posts.count - 1 {
            cell.includeBottomConnector()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let cell = cell as! JournalHeaderCollectionViewCell
            cell.descriptionLabel.text = journal?.description!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            paragraphStyle.alignment = .center
            let attrString = NSMutableAttributedString(string: (journal?.description!)!)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            cell.descriptionLabel.attributedText = attrString
            return
        }
        
        let post = posts[indexPath.item]
        let currUserId = FIRAuth.auth()?.currentUser?.uid
        var genericPostCell: PostCollectionViewCell!
        if post.imageUrl == nil && post.content != nil {
            let postCell = cell as! TextPostCollectionViewCell
            postCell.contentLabel.text = post.content!
            genericPostCell = postCell
        } else if post.imageUrl != nil && post.content != nil {
            let postCell = cell as! ImageTextPostCollectionViewCell
            postCell.contentLabel.text = post.content!
            post.getImage(withBlock: { retrievedImage -> Void in
                postCell.imageView.image = retrievedImage
            })
            genericPostCell = postCell
        } else {
            let postCell = cell as! ImagePostCollectionViewCell
            post.getImage(withBlock: { retrievedImage -> Void in
                postCell.imageView.image = retrievedImage
            })
            genericPostCell = postCell
        }
        genericPostCell.post = post
        post.getPoster(withBlock: { retrievedUser -> Void in
            genericPostCell.usernameLabel.text = retrievedUser.name!
            retrievedUser.getProfPic(withBlock: { retrievedImage -> Void in
                genericPostCell.profPicImageView.image = retrievedImage
            })
        })
        if (post.likedUserIds?.contains(currUserId!))! {
            genericPostCell.setLiked()
        }
        genericPostCell.likesLabel.text = "\(post.likedUserIds!.count)"
        genericPostCell.commentsLabel.text = "\(post.commentIds!.count)"
        if post.date != nil {
            let calendar = Calendar(identifier: .gregorian)
            let dateComponents = calendar.dateComponents([.day, .month], from: post.date!)
            let month = Constants.months[dateComponents.month! - 1]
            let day = dateComponents.day!
            genericPostCell.dayLabel.text = String(describing: day)
            genericPostCell.monthLabel.text = month
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            let headerCellSizeAttr = CellSizeCalculator.sizeForHeaderCell(withJournal: journal!)
            return CGSize(width: view.frame.width, height: headerCellSizeAttr.cellHeight!)
        }
        
        let post = posts[indexPath.item]
        let cellSizeAttr = CellSizeCalculator.sizeForPostCell(withPost: post)
        
        return CGSize(width: view.frame.width, height: cellSizeAttr.cellContainerHeight! + 60)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        selectedPost = posts[indexPath.item]
        performSegue(withIdentifier: "toPostDetail", sender: self)
    }

    
}

extension PostsViewController: InviteViewDelegate {
    func dismissView() {
        modalView.dismiss()
    }
    
    func inviteCollaborator(withId: String) {
        modalView.dismiss()
        if (journal?.contributorIds?.contains(withId))! {
            let alert = UIAlertController(title: "Cannot Invite User", message: "The user you selected is already a contributor to this journal", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let newInvite = Invite(receiverIdValue: withId, isAContributor: true, journalIdValue: (journal?.journalId)!)
        hud?.textLabel.text = "Sending..."
        hud?.show(in: view)
        newInvite.send(withBlock: { success -> Void in
            self.hud?.dismiss()
        })
    }
    
    func inviteObserver(withId: String) {
        modalView.dismiss()
        if (journal?.observerIds?.contains(withId))! {
            let alert = UIAlertController(title: "Cannot Invite User", message: "The user you selected is already an observer to this journal", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else if (journal?.contributorIds?.contains(withId))! {
            let alert = UIAlertController(title: "Cannot Invite User", message: "The user you selected is already a contributor to this journal", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let newInvite = Invite(receiverIdValue: withId, isAContributor: false, journalIdValue: (journal?.journalId)!)
        hud?.textLabel.text = "Sending..."
        hud?.show(in: view)
        newInvite.send(withBlock: { success -> Void in
            self.hud?.dismiss()
        })
    }
    
    func getUsers(withPrefix: String, withBlock: @escaping ([User]) -> Void) {
        InkwireDBUtils.getUsersByName(prefix: withPrefix, withBlock: { retrievedUsers -> Void in
            withBlock(retrievedUsers)
        })
    }
}

extension PostsViewController: PostCollectionViewCellDelegate {
    func urlTapped(url: String) {
        if let checkedUrl = URL(string: url) {
            UIApplication.shared.openURL(checkedUrl)
        }
    }
}
