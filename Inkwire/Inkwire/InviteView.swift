//
//  InviteView.swift
//  Inkwire
//
//  Created by Akkshay Khoslaa on 11/16/16.
//  Copyright © 2016 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import Firebase
protocol InviteViewDelegate {
    func dismissView()
    func inviteCollaborator(withId: String)
    func inviteObserver(withId: String)
    func getUsers(withPrefix: String, withBlock: @escaping ([User]) -> Void)
}

class InviteView: UIView {
    
    var usernameTextField:UITextField!
    var delegate: InviteViewDelegate? = nil
    var tableView: UITableView!
    var users = [User]()
    var numUsers = 0
    var debounceTimer: Timer?
    var searchWord = ""
    var selectedCell: UserTableViewCell?
    var selectedUserId: String?
    var headerBar: UIView!
    var titleLabel: UILabel!
    var dismissButton: UIButton!
    var inviteCollabButton: UIButton!
    var inviteObserverButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        layer.cornerRadius = 5
        clipsToBounds = true
        
        setUpHeaderItems()
        setUpUsernameTextField()
        setUpTableView()
        setUpInviteButtons()
    }
    
    override func didMoveToSuperview() {
        usernameTextField.becomeFirstResponder()
    }
    
    func setUpHeaderItems() {
        headerBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        headerBar.backgroundColor = Constants.appColor
        addSubview(headerBar)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerBar.frame.width, height: 50))
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "SFUIText-Regular", size: 18)
        titleLabel.textAlignment = .center
        titleLabel.text = "Invite"
        headerBar.addSubview(titleLabel)
        
        dismissButton = UIButton(frame: CGRect(x: 15, y: (headerBar.frame.height - 20)/2, width: 20, height: 20))
        dismissButton.setImage(UIImage(named: "x"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        headerBar.addSubview(dismissButton)
    }
    
    func setUpUsernameTextField() {
        usernameTextField = UITextField(frame: CGRect(x: 15, y: headerBar.frame.maxY + 10, width: frame.width - 30, height: 30))
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.placeholder = "Search by name"
        usernameTextField.font = UIFont(name: "SFUIText-Regular", size: 14)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: usernameTextField.frame.height))
        usernameTextField.leftView = paddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addSubview(usernameTextField)
    }
    
    func setUpTableView() {
        tableView = UITableView(frame: CGRect(x: 15, y: usernameTextField.frame.maxY + 10, width: frame.width - 30, height: 120))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "userCell")
        tableView.backgroundColor = UIColor.white
        addSubview(tableView)
    }
    
    /** 
     Setup UI for buttons that invite collaborators or observers to journals.
     */
    func setUpInviteButtons() {
        inviteCollabButton = UIButton(frame: CGRect(x: 15, y: tableView.frame.maxY + 10, width: frame.width - 30, height: 45))
        inviteCollabButton.layer.cornerRadius = inviteCollabButton.frame.height/2
        inviteCollabButton.clipsToBounds = true
        inviteCollabButton.backgroundColor = Constants.appColor
        inviteCollabButton.setTitleColor(UIColor.white, for: .normal)
        inviteCollabButton.setTitle("Invite as Collaborator", for: .normal)
        inviteCollabButton.addTarget(self, action: #selector(inviteCollabTapped), for: .touchUpInside)
        addSubview(inviteCollabButton)
        
        inviteObserverButton = UIButton(frame: CGRect(x: 15, y: inviteCollabButton.frame.maxY + 10, width: frame.width - 30, height: 45))
        inviteObserverButton.layer.cornerRadius = inviteCollabButton.frame.height/2
        inviteObserverButton.clipsToBounds = true
        inviteObserverButton.backgroundColor = UIColor(hex: "#E1492A")
        inviteObserverButton.setTitleColor(UIColor.white, for: .normal)
        inviteObserverButton.setTitle("Invite as Observer", for: .normal)
        inviteObserverButton.addTarget(self, action: #selector(inviteObserverTapped), for: .touchUpInside)
        addSubview(inviteObserverButton)
    }
    
    func dismissButtonTapped() {
        delegate?.dismissView()
    }
    
    func inviteCollabTapped() {
        if selectedUserId != nil {
            delegate?.inviteCollaborator(withId: selectedUserId!)
        }
    }
    
    func inviteObserverTapped() {
        if selectedUserId != nil {
            delegate?.inviteObserver(withId: selectedUserId!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getUsers() {
        delegate?.getUsers(withPrefix: searchWord, withBlock: { retrievedUsers -> Void in
            self.users = retrievedUsers
            self.numUsers = retrievedUsers.count
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension InviteView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCell != nil {
            selectedCell?.accessoryType = .none
        }
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        cell.accessoryType = .checkmark
        selectedCell = cell
        selectedUserId = users[indexPath.item].userId
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numUsers
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.awakeFromNib()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        let cell = cell as! UserTableViewCell
        cell.nameLabel.text = user.name!
        user.getProfPic(withBlock: { retrievedImage -> Void in
            cell.profPicImageView.image = retrievedImage
        })
    }
}

// MARK: - UITextFieldDelegate
extension InviteView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        getUsers()
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        searchWord = textField.text!
        
        if let timer = debounceTimer {
            timer.invalidate()
        }
        
        debounceTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(getUsers), userInfo: nil, repeats: false)
        RunLoop.current.add(debounceTimer!, forMode: .defaultRunLoopMode as RunLoopMode)
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
