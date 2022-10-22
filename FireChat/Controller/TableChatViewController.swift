//  TableChatViewController.swift
//  Validation
//  Created by hari-pt5664 on 22/08/22.

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol SignOutActionDelegate: AnyObject {
    func actionSignedOut()
}

protocol CreateGroupActionDelegate: AnyObject {
    func actionCreateGroup(gName: String)
}

//MARK: - User Names, Groups Tableview Controller

class TableChatViewController: UIViewController {
    @IBOutlet weak var userNameTableView: UITableView!
    
    var currentUserId = String()
    var currentUserName = String()
    var createGroupId = String()
    private var createGroupButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        let image = UIImage(systemName: "plus.message.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25,
                                                                                                            weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(createGroupButton)
        createGroupButton.addTarget(self,
                                    action: #selector(groupCreationTapped),
                                    for: .touchUpInside)
        userNameTableView.delegate = self
        userNameTableView.dataSource = self
        
        self.userNameTableView.layer.borderColor = UIColor.darkGray.cgColor
        self.userNameTableView.layer.borderWidth = 1;
        self.userNameTableView.layer.cornerRadius = 10.0
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(signOutTapped))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createGroupButton.frame = CGRect(x: view.frame.size.width - 70,
                                         y: view.frame.size.height - 90,
                                         width: 50, height: 50)
    }
    
    func assignUserId (userID: String) {
        self.currentUserId = userID
    }
    
    func assignUserName (userName: String) {
        self.currentUserName = userName
    }
    
    @objc func signOutTapped() {
        if let signoutViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "SignOutViewController") as? SignOutViewController {
            signoutViewController.actionDelegate = self
            self.present(signoutViewController, animated: true)
        }
    }
    
    @objc func groupCreationTapped() {
        if let groupCreationViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "GroupCreationViewController") as? GroupCreationViewController {
            groupCreationViewController.delegate = self
            self.present(groupCreationViewController, animated: true)
        }
    }
    
    private func signoutUser() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        AppConstants.userNames.removeAll()
        AppConstants.groupNames.removeAll()
        if let navigationController = self.navigationController as? MainViewController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    private func createGroup(groupName: String) {
        let length = 15
        let timeStamp = NSDate().timeIntervalSince1970
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        self.createGroupId = String((0..<length).map { _ in letters.randomElement()! })
        
        AppConstants.dataBase.collection("UserDatabase").document(self.createGroupId).setData([
            "Created_UserId": self.currentUserId,
            "Created_UserName" : self.currentUserName,
            "Created_E-Mail" : (Auth.auth().currentUser?.email)! as String,
            "Group_Name" : groupName,
            "Group_ID" : self.createGroupId,
            "Created_Time" : timeStamp,
            "Members_Count" : "1" ])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        loadGroupCreation()
    }
    
    private func loadGroupCreation() {
        let timeStamp = NSDate().timeIntervalSince1970
        AppConstants.dataBase.collection("UserDatabase").document(self.createGroupId).collection("Group_Members_Data").document("\(self.currentUserName)").setData([
            "User_Name" : self.currentUserName ,
            "User_ID" : self.currentUserId ,
            "Added_Time" : timeStamp
        ])
        
        AppConstants.dataBase.collection("UserDatabase").document(self.createGroupId).getDocument { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            AppConstants.userDetails.append(data)
            if let id = data["Group_ID"] as? String, let name = data["Group_Name"] as? String {
                AppConstants.groupIds.append(id)
                AppConstants.groupNames.append(name)
            }
        }
    }
    
    func presentMessageVC (otherUserId: String,
                           otherUserName: String) {
        if let navigationController = self.navigationController as? MainViewController,
           let messageViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
            messageViewController.usersData(userID1: self.currentUserId, userID2: otherUserId, userName1: currentUserName, userName2: otherUserName)
            navigationController.pushViewController(messageViewController, animated: true)
        }
    }
}

//MARK: - UITableViewDelegate

extension TableChatViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if indexPath.section % 2 == 0 {
            presentMessageVC (otherUserId: AppConstants.userIds[indexPath.row], otherUserName: AppConstants.userNames[indexPath.row] )
        } else {
            presentMessageVC(otherUserId: AppConstants.groupIds[indexPath.row], otherUserName: AppConstants.groupNames[indexPath.row])
        }
        userNameTableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension TableChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return AppConstants.userNames.count
        } else {
            return AppConstants.groupNames.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userNameTableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath)
        if indexPath.section % 2 == 0 {
            cell.textLabel?.text = AppConstants.userNames[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            cell.textLabel?.text = AppConstants.groupNames[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
}

//MARK: - SignOut Delegate

extension TableChatViewController: SignOutActionDelegate {
    func actionSignedOut() {
        self.signoutUser()
    }
}

//MARK: - Group Creation Delegate

extension TableChatViewController: CreateGroupActionDelegate {
    func actionCreateGroup(gName: String) {
        self.createGroup(groupName: gName)
    }
}
