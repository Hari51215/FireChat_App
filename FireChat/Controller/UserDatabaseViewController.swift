//  SecondPageViewController.swift
//  Validation
//  Created by hari-pt5664 on 11/08/22.

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

//MARK: - Cloud Firestore Class

class UserDatabaseViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var submitMessageView: UITextView!
    
    var groupDocArray: [QueryDocumentSnapshot] = []
    private var userId = String()
    private var emailId = String()
    var userIdName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUID(userID: String, emailID: String) {
        self.userId = userID
        self.emailId = emailID
    }
    
    @IBAction func actionSubmitButton(_ sender: Any) {
        let userName = self.userNameTextField.text
        let phoneNumber = self.contactNumberTextField.text
        AppConstants.dataBase.collection("UserDatabase").document(userId).setData([
            "User_ID": userId,
            "User_Name" : userName!,
            "Phone_Number" : phoneNumber!,
            "E-Mail" : emailId ])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        submitMessageView.isHidden = false
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.submitMessageView.alpha = 0
        })
        submitMessageView.text = "Submitted Successfully"
        
        if let mainNavigationViewController = self.navigationController as? MainViewController,
           let tableViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "TableChatViewController") as? TableChatViewController {
            mainNavigationViewController.popViewController(animated: true)
            tableViewController.assignUserId(userID: userId)
            tableViewController.assignUserName(userName: userName!)
            mainNavigationViewController.pushViewController(tableViewController, animated: true)
        }
    }
    
    func checkUserDetails (userId: String,
                           userName: String,
                           fileCheck: Bool,
                           completion : @escaping (Bool, String) -> Void) {
        var count = 0
        var documentCheck = fileCheck
        var userIdName = userName
            
        AppConstants.dataBase.collection("UserDatabase").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                AppConstants.groupIds.removeAll()
                AppConstants.groupNames.removeAll()
                AppConstants.userDetails.removeAll()
                AppConstants.userIds.removeAll()
                AppConstants.userNames.removeAll()
                for document in querySnapshot!.documents {
                    AppConstants.userDetails.append(document.data())
                    if document.documentID.count == 15 {
                        if document.data()["Created_UserId"] as! String == self.userId {
                            AppConstants.groupIds.append(document["Group_ID"] as! String)
                            AppConstants.groupNames.append(document["Group_Name"] as! String)
                        } else {
                            self.groupDocArray.append(document)
                        }
                    } else {
                        if document.documentID == self.userId {
                            count+=1
                        }
                        if document.documentID != self.userId {
                            AppConstants.userIds.append(document["User_ID"] as! String)
                            AppConstants.userNames.append(document["User_Name"] as! String)
                        } else {
                            let userNow = document.data()
                            userIdName = userNow["User_Name"] as! String
                        }
                    }
                }
                if count == 0 {
                    documentCheck = true
                } else {
                    documentCheck = false
                }
                func processResponse(groupId: String,
                                     groupName: String) {
                    if groupId != "" && groupName != "" {
                        AppConstants.groupIds.append(groupId)
                        AppConstants.groupNames.append(groupName)
                    }
                    if self.groupDocArray.count > 0 {
                        let group = self.groupDocArray.removeFirst()
                        self.groupDocuments(_document: group, completion: processResponse(groupId:groupName:))
                    } else {
                        completion(documentCheck, userIdName)
                    }
                }
                if self.groupDocArray.count > 0 {
                    let group = self.groupDocArray.removeFirst()
                    self.groupDocuments(_document: group, completion: processResponse(groupId:groupName:))
                } else {
                    completion(documentCheck, userIdName)
                }
            }
        }
    }
    
    func groupDocuments (_document: QueryDocumentSnapshot,
                         completion: @escaping (String, String) -> Void) {
        var groupId = String()
        var groupName = String()
        AppConstants.dataBase.collection("UserDatabase").document(_document.documentID).collection("Group_Members_Data").getDocuments() { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let snapshot = snapshot,
                   snapshot.documents.count > 0 {
                    for _document_ in snapshot.documents {
                        if _document_.data()["User_ID"] as! String == self.userId {
                            groupId = _document.data()["Group_ID"] as! String
                            groupName = _document.data()["Group_Name"] as! String
                        }
                    }
                }
                completion(groupId,groupName)
            }
        }
    }
}
