//  AddPersonViewController.swift
//  Validation
//  Created by hari-pt5664 on 14/09/22.

import UIKit

struct UserDataStructure {
    let userId: String
    let userName: String
    var isSelected: Bool
    var isFiltered: Bool
}

//MARK: - Add Member Class

class AddPersonViewController: UIViewController {
    public weak var delegate: AddPersonActionDelegate?
    @IBOutlet weak var addPersonTableView: UITableView!
    var userData: [UserDataStructure] = []
    var addPersonArray: [UserDataStructure] = []
    let cancelButtonLabel = UILabel()
    let addButtonLabel = UILabel()
    var groupId = String()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    func getGroupId(group: String) {
        self.groupId = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData.removeAll()
        loadMembers(completion: {_ in ()})
        addPersonTableView.delegate = self
        addPersonTableView.dataSource = self
        self.addPersonTableView.layer.borderColor = UIColor.darkGray.cgColor
        self.addPersonTableView.layer.borderWidth = 1;
        self.addPersonTableView.layer.cornerRadius = 10.0
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "No Users Selected"
        
        cancelButtonLabel.text = "Cancel"
        cancelButtonLabel.textColor = .systemBlue
        let cancelTapGesture = UITapGestureRecognizer(target: self,
                                                      action: #selector(self.actionCancelDidTap(_:)))
        cancelButtonLabel.addGestureRecognizer(cancelTapGesture)
        cancelButtonLabel.isUserInteractionEnabled = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButtonLabel)
        
        addButtonLabel.text = "Add"
        addButtonLabel.textColor = .red
        let addTapGesture = UITapGestureRecognizer(target: self,
                                                   action: #selector(self.actionAddDidTap(_:)))
        addButtonLabel.addGestureRecognizer(addTapGesture)
        addButtonLabel.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButtonLabel)
    }
    
    @objc private func actionCancelDidTap(_ sender: UITapGestureRecognizer) {
        cancelButtonLabel.textColor = .red
        self.dismiss(animated: true)
    }
    
    @objc private func actionAddDidTap(_ sender: UITapGestureRecognizer) {
        if !addPersonArray.isEmpty {
            self.dismiss(animated: true)
            self.delegate?.actionAddPerson(newMembers: self.addPersonArray)
        }
    }
    
    private func loadMembers(completion:@escaping(([UserDataStructure]) -> ())) {
        AppConstants.dataBase.collection("UserDatabase").document(self.groupId).collection("Group_Members_Data").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for index in 0..<AppConstants.userNames.count {
                    let data = UserDataStructure(userId: AppConstants.userIds[index],
                                                 userName: AppConstants.userNames[index],
                                                 isSelected: false,
                                                 isFiltered: true)
                    self.userData.append(data)
                }
                if let snapshot = snapshot,
                   snapshot.documents.count > 0 {
                    for _document in snapshot.documents {
                        for (index, user) in self.userData.enumerated() {
                            if _document.data()["User_ID"] as! String == user.userId {
                                self.userData.remove(at: index)
                                break
                            }
                        }
                    }
                }
            }
            completion(self.userData)
            self.addPersonTableView.reloadData()
        }
    }
    
    private func getUserNames() -> [String] {
        var _userNames: [String] = []
        for userDatum in self.userData where userDatum.isFiltered {
            _userNames.append(userDatum.userName)
        }
        return _userNames
    }
    
    private func getSelectedCount() -> Int {
        var count = 0
        self.addPersonArray.removeAll()
        for userDatum in self.userData where userDatum.isSelected {
            count += 1
            self.addPersonArray.append(userDatum)
        }
        if !addPersonArray.isEmpty {
            addButtonLabel.textColor = .systemBlue
        } else {
            addButtonLabel.textColor = .red
        }
        return count
    }
}

//MARK: - UITableViewDelegate

extension AddPersonViewController : UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        self.addPersonTableView.deselectRow(at: indexPath,
                                            animated: true)
        for index in 0..<self.userData.count {
            if self.userData[index].userName == self.getUserNames()[indexPath.row] {
                self.userData[index].isSelected.toggle()
            }
        }
        var countTitle = self.getSelectedCount() == 0 ? "No" : String(self.getSelectedCount())
        self.getSelectedCount() < 2 ? countTitle.append(" User ") : countTitle.append(" Users ")
        countTitle.append("Selected")
        self.navigationItem.title = countTitle
        self.addPersonTableView.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension AddPersonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.getUserNames().count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addPersonTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.getUserNames()[indexPath.row]
        for userDatum in self.userData where self.getUserNames()[indexPath.row] == userDatum.userName {
            cell.accessoryType = userDatum.isSelected ? .checkmark : .none
        }
        return cell
    }
}

//MARK: - SearchBar Delegate

extension AddPersonViewController: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        for index in 0..<self.userData.count {
            self.userData[index].isFiltered = self.userData[index].userName.uppercased().contains(searchText.uppercased())
        }
        if searchText.isEmpty {
            for index in 0..<self.userData.count {
                self.userData[index].isFiltered = true
            }
        }
        self.addPersonTableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        for index in 0..<self.userData.count {
            self.userData[index].isFiltered = true
        }
        self.addPersonTableView.reloadData()
    }
}
