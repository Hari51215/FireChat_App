//  GroupCreationViewController.swift
//  Validation
//  Created by hari-pt5664 on 12/09/22.

import UIKit

//MARK: - Group Creation Class

class GroupCreationViewController: UIViewController {
    weak var delegate: CreateGroupActionDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        groupNameTextField.delegate = self
        cancelButton.setTitle("Cancel", for: .normal)
        createButton.setTitle("Create", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        createButton.isEnabled = (groupNameTextField.text?.count ?? 0) > 0
    }
    
    @IBAction private func handleCloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func handleCreateButtonTapped(_ sender: Any) {
        if let groupName = groupNameTextField.text {
            self.dismiss(animated: true)
            self.delegate?.actionCreateGroup(gName: groupName)
        }
    }
}

//MARK: - UITextFieldDelegate

extension GroupCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnTextName = groupNameTextField.text {
            self.dismiss(animated: true)
            self.delegate?.actionCreateGroup(gName: returnTextName)
        }
        
        groupNameTextField.resignFirstResponder()
        groupNameTextField.text = ""
        self.createButton.isEnabled = false
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if groupNameTextField.text != "" {
            return true
        } else {
            groupNameTextField.placeholder = "Enter the Group Name !!!"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        groupNameTextField.text = ""
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField ==  groupNameTextField else { return true }
        let newLength = (textField.text?.count ?? 0) - range.length + string.count
        createButton.isEnabled = newLength > 0
        return true
    }
}
