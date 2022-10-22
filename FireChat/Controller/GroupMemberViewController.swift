//  GroupMemberViewController.swift
//  Validation
//  Created by hari-pt5664 on 20/09/22.

import UIKit
import FirebaseCore
import FirebaseFirestore

struct GroupMembersData {
    var name: String
    var id: String
    var isSelected: Bool
}

//MARK: - Group Member List Class

class GroupMemberViewController: UIViewController {
    public weak var delegate: RemovePersonActionDelegate?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var groupMemberTableView: UITableView!
    
    var groupMemberArray: [GroupMembersData] = []
    var removeMemberArray: [GroupMembersData] = []
    var currentGroupId = String()
    var groupCreatedId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupMemberTableView.layer.borderColor = UIColor.darkGray.cgColor
        self.groupMemberTableView.layer.borderWidth = 1;
        self.groupMemberTableView.layer.cornerRadius = 10.0
        groupMemberTableView.delegate = self
        groupMemberTableView.dataSource = self
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.setTitleColor(.systemBlue, for: .normal)
        self.removeButton.setTitle("Remove", for: .normal)
        self.removeButton.isEnabled = false
        self.groupMemberArray.removeAll()
        getGroupCreater()
        loadGroupMemberData()
    }
    
    func configure(groupId: String) {
        self.currentGroupId = groupId
    }
    
    @IBAction private func handleCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func handleRemoveButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
        self.delegate?.actionRemovePerson(removeMembers: self.removeMemberArray)
    }
    
    func getGroupCreater() {
        AppConstants.dataBase.collection("UserDatabase").document(self.currentGroupId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if let data = document.data() {
                self.groupCreatedId = data["Created_UserId"] as! String
            }
        }
    }
    
    func loadGroupMemberData() {
        AppConstants.dataBase.collection("UserDatabase").document(self.currentGroupId).collection("Group_Members_Data").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            for document in documents {
                let memberName = document.data()["User_Name"] as! String
                let memberId = document.data()["User_ID"] as! String
                let member = GroupMembersData.init(name: memberName, id: memberId, isSelected: false)
                self.groupMemberArray.append(member)
            }
            self.groupMemberTableView.reloadData()
        }
    }
}

//MARK: - UITableViewDelegate

extension GroupMemberViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.removeMemberArray.removeAll()
        groupMemberTableView.deselectRow(at: indexPath, animated: true)
        
        for index in 0..<self.groupMemberArray.count {
            if self.groupMemberArray[index].name == groupMemberArray[indexPath.row].name && self.groupCreatedId != groupMemberArray[indexPath.row].id {
                self.groupMemberArray[index].isSelected.toggle()
            }
        }
        for member in groupMemberArray where member.isSelected {
            self.removeMemberArray.append(member)
        }
        if !removeMemberArray.isEmpty {
            self.removeButton.isEnabled = true
            self.removeButton.setTitleColor(.systemBlue, for: .normal)
        } else {
            self.removeButton.isEnabled = false
        }
        self.groupMemberTableView.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension GroupMemberViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupMemberArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupMemberTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let userNameAttributedString = NSMutableAttributedString(string: "")
        let adminAttributedText = NSAttributedString(string: "(Admin)")
        userNameAttributedString.append(NSAttributedString(string: self.groupMemberArray[indexPath.row].name))

        if self.groupCreatedId == self.groupMemberArray[indexPath.row].id {
            userNameAttributedString.append(adminAttributedText)
            let range = (userNameAttributedString.string as NSString).range(of: adminAttributedText.string)
            userNameAttributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                  value: UIColor.red,
                                                  range: range)
            userNameAttributedString.addAttribute(NSAttributedString.Key.font,
                                                  value: UIFont.systemFont(ofSize: 10), range: range)
        }
        cell.textLabel?.attributedText = userNameAttributedString

        for member in groupMemberArray {
            if groupMemberArray[indexPath.row].name ==  member.name {
                cell.accessoryType = member.isSelected ? .checkmark : .none
            }
        }
        return cell
    }
}
