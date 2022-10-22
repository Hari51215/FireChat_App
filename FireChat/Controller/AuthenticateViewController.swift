//  ViewController.swift
//  Validation
//  Created by hari-pt5664 on 05/08/22.

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

//MARK: User Authentication

class AuthenticateViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var uID: String?
    var eID: String?
    var uName = String()
    let documentCheck = Bool()
    var userExist = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userExist = validateUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userExist {
            if let userDatabaseViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "UserDatabaseViewController") as? UserDatabaseViewController,
               let userId = Auth.auth().currentUser?.uid, let emailId = Auth.auth().currentUser?.email {
                userDatabaseViewController.setUID(userID: userId, emailID: emailId)
                userDatabaseViewController.checkUserDetails(userId: userId, userName: self.uName, fileCheck: self.documentCheck, completion: { (documentCheck, userIdName) -> Void in
                    if !documentCheck {
                        if let mainNavigationViewController = self.navigationController as? MainViewController,
                           let tableViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "TableChatViewController") as? TableChatViewController {
                            tableViewController.assignUserId(userID: userId)
                            tableViewController.assignUserName(userName: userIdName)
                            mainNavigationViewController.pushViewController(tableViewController, animated: false)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
                if error != nil {
                    return
                }
                guard let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    return
                }
                
                let credential = GoogleAuthProvider.credential (withIDToken: idToken, accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential) { [weak self] authResult , error in
                    guard let _ = error else {
                        self?.uID = FirebaseAuth.Auth.auth().currentUser?.uid
                        self?.eID = FirebaseAuth.Auth.auth().currentUser?.email
                        if let userDatabaseViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "UserDatabaseViewController") as? UserDatabaseViewController,
                           let userId = self?.uID {
                            userDatabaseViewController.setUID(userID: userId, emailID: (self?.eID)!)
                            userDatabaseViewController.checkUserDetails(userId: userId, userName: self!.uName, fileCheck: self!.documentCheck, completion: { (documentCheck, userIdName) -> Void in
                                if documentCheck {
                                    if let mainNavigationViewController = self?.navigationController as? MainViewController {
                                        mainNavigationViewController.pushViewController(userDatabaseViewController, animated: true)
                                    }
                                } else {
                                    if let mainNavigationViewController = self?.navigationController as? MainViewController,
                                       let tableViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "TableChatViewController") as? TableChatViewController {
                                        tableViewController.assignUserId(userID: userId)
                                        tableViewController.assignUserName(userName: userIdName)
                                        mainNavigationViewController.pushViewController(tableViewController, animated: true)
                                    }
                                }
                            })
                        }
                        return
                    }
                    print(error!)
                }
            }
        }
    }
    
    func validateUser () -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            print("No user Found !")
            return false
        }
    }
}
