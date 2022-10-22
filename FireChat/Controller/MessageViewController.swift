//  MessageViewController.swift
//  Validation
//  Created by hari-pt5664 on 17/08/22.

import UIKit
import Photos
import FirebaseStorage
import FirebaseFirestore

protocol RemovePersonActionDelegate: AnyObject {
    func actionRemovePerson(removeMembers: [GroupMembersData])
}

protocol AddPersonActionDelegate: AnyObject {
    func actionAddPerson(newMembers: [UserDataStructure])
}

//MARK: - Message Conversion Class

class MessageViewController: UIViewController {
    struct TextChat {
        var name: String
        var message: String
        var time: String
        var type: String
    }
    
    enum MessageType: String {
        case text = "text"
        case image = "image"
    }
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var conversionTableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    let titleButtonLabel = UILabel()
    var senderUserId = String()
    var senderUserName = String()
    var receiverUserId = String()
    var receiverUserName = String()
    var user_1 = String()
    var user_2 = String()
    var sortingArray = [String]()
    var messagesArray = [TextChat]()
    var messageCount = 0
    var memberCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversionTableView.layer.borderColor = UIColor.darkGray.cgColor
        self.conversionTableView.layer.borderWidth = 1;
        self.conversionTableView.layer.cornerRadius = 10.0
        
        if self.receiverUserId.count == 15 {
            let titleContainer = UIView()
            titleContainer.frame = CGRect(x: 0,
                                          y: 0,
                                          width: 200,
                                          height: 40)
            let button = UIButton(type: .custom)
            button.setTitle(self.receiverUserName,
                            for: .normal)
            button.setTitleColor(.systemBlue,
                                 for: .normal)
            button.frame = titleContainer.frame
            button.addTarget(self,
                             action: #selector(didTappedGroupMemberList),
                             for: .touchUpInside)
            titleContainer.addSubview(button)
            self.navigationItem.titleView = titleContainer
            
            checkConversionType(completion: { checkGroupAdmin in
                if checkGroupAdmin {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.fill.badge.plus"),
                                                                             style: .plain,
                                                                             target: self,
                                                                             action: #selector(self.didTappedAddPerson))
                }
            })
        } else {
            self.navigationItem.title = self.receiverUserName
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        conversionTableView.register(LeftTableViewCell.cellNib, forCellReuseIdentifier: "leftcell")
        conversionTableView.register(RightTableViewCell.cellNib, forCellReuseIdentifier: "rightcell")
        conversionTableView.register(LeftImageTableViewCell.cellNib, forCellReuseIdentifier: "leftimagecell")
        conversionTableView.register(RightImageTableViewCell.cellNib, forCellReuseIdentifier: "rightimagecell")
        conversionTableView.register(TextTableViewCell.cellNib, forCellReuseIdentifier: "TextTableViewCell")
        conversionTableView.register(ImageTableViewCell.cellNib, forCellReuseIdentifier: "ImageTableViewCell")
        conversionTableView.separatorStyle = .none
        
        messageTextField.delegate = self
        conversionTableView.delegate = self
        conversionTableView.dataSource = self
        observeMemberCount()
        observeMessageCount()
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        sendButton.isEnabled = (messageTextField.text?.count ?? 0) > 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    func checkConversionType (completion: @escaping (Bool) -> Void) {
        var adminId = ""
        AppConstants.dataBase.collection("UserDatabase").document(self.receiverUserId).addSnapshotListener {documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if let data = document.data() {
                adminId = data["Created_UserId"] as! String
            }
            if self.receiverUserId.count == 15 && self.senderUserId == adminId {
                completion (true)
            }
            completion (false)
        }
    }
    
    func usersData(userID1 : String, userID2: String, userName1: String, userName2: String) {
        self.senderUserId = userID1
        self.receiverUserId = userID2
        self.senderUserName = userName1
        self.receiverUserName = userName2
        
        sortingArray.append(senderUserId)
        sortingArray.append(receiverUserId)
        sortingArray.sort()
        self.user_1 = sortingArray[0]
        self.user_2 = sortingArray[1]
    }
    
    @objc private func didTappedGroupMemberList() {
        if let groupMemberViewController = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "GroupMemberViewController") as? GroupMemberViewController {
            groupMemberViewController.configure(groupId: self.receiverUserId)
            groupMemberViewController.delegate = self
            self.present(groupMemberViewController, animated: true)
        }
    }
    
    @objc private func didTappedAddPerson() {
        if let navVC = AppConstants.mainStoryBoard.instantiateViewController(withIdentifier: "AddPersonNavigationController") as? UINavigationController,
           let addPersonViewController = navVC.topViewController as? AddPersonViewController {
            addPersonViewController.delegate = self
            addPersonViewController.getGroupId(group: self.receiverUserId)
            self.present(navVC, animated: true)
        }
    }
    
    private func observeMemberCount() {
        memberCount = 1
        AppConstants.dataBase.collection("UserDatabase").document(self.receiverUserId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let memberCountData = document.data() else {
                print("Document data was empty.")
                return
            }
            if let memberCountValue = memberCountData["Members_Count"] as? Int {
                self.memberCount = memberCountValue
            }
        }
    }
    
    @IBAction func messageSend(_ sender: UIButton) {
        if let userMessage = messageTextField.text {
            sendMessages(sentMessage: userMessage, messageType: MessageType.text.rawValue)
        }
        messageTextField.text = ""
        self.sendButton.isEnabled = false
    }
    
    @IBAction func attachFile(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    private func addMember(addPersonList: [UserDataStructure]) {
        self.memberCount += addPersonList.count
        let membersCount = addPersonList.count
        let timeStamp = NSDate().timeIntervalSince1970
        
        AppConstants.dataBase.collection("UserDatabase").document(self.receiverUserId).updateData(["Members_Count" : self.memberCount])
        
        for member in 0..<membersCount {
            AppConstants.dataBase.collection("UserDatabase").document(self.receiverUserId).collection("Group_Members_Data").document("\(addPersonList[member].userName)").setData([
                "User_Name" : addPersonList[member].userName ,
                "User_ID" : addPersonList[member].userId ,
                "Added_Time" : timeStamp
            ])
        }
    }
    
    private func removeMember(removePersonList: [GroupMembersData]) {
        
        for person in 0..<removePersonList.count{
            AppConstants.dataBase.collection("UserDatabase").document(self.receiverUserId).collection("Group_Members_Data").document(removePersonList[person].name).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        self.memberCount -= removePersonList.count
        AppConstants.dataBase.collection("UserDatabase").document(self.receiverUserId).updateData(["Members_Count" : self.memberCount])
    }
    
    func sendMessages(sentMessage: String, messageType: String) {
        let message = sentMessage
        messageCount+=1
        if self.receiverUserId.count == 15 {
            AppConstants.dataBase.collection("User_Conversions").document("Group_\(self.receiverUserId)").setData(["Document_Count" : messageCount])
            
            let timeStamp = NSDate().timeIntervalSince1970
            AppConstants.dataBase.collection("User_Conversions").document("Group_\(self.receiverUserId)").collection("Group_Conversion").document("\(senderUserName)_message_\(messageCount)").setData(["SenderUserID": senderUserId , "UserName": senderUserName , "Message" : message, "TimeStamp" : timeStamp, "MessageType" : messageType])
        } else {
            AppConstants.dataBase.collection("User_Conversions").document("\(user_1)_TO_\(user_2)").setData(["Document_Count" : messageCount])
            
            let timeStamp = NSDate().timeIntervalSince1970
            AppConstants.dataBase.collection("User_Conversions").document("\(user_1)_TO_\(user_2)").collection("Conversion").document("\(senderUserName)_message_\(messageCount)").setData(["SenderUserID": senderUserId , "UserName": senderUserName , "Message" : message, "TimeStamp" : timeStamp, "MessageType" : messageType])
        }
    }
    
    private func observeMessageCount () {
        messageCount = 0
        if self.receiverUserId.count == 15 {
            AppConstants.dataBase.collection("User_Conversions").document("Group_\(self.receiverUserId)").addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let countData = document.data() else {
                    print("Document data was empty.")
                    return
                }
                if let countValue = countData["Document_Count"] as? Int {
                    self.messageCount = countValue
                }
            }
        } else {
            AppConstants.dataBase.collection("User_Conversions").document("\(user_1)_TO_\(user_2)").addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let countData = document.data() else {
                    print("Document data was empty.")
                    return
                }
                if let countValue = countData["Document_Count"] as? Int {
                    self.messageCount = countValue
                }
            }
        }
    }
    
    private func observeMessages() {
        if self.receiverUserId.count == 15 {
            AppConstants.dataBase.collection("User_Conversions").document("Group_\(self.receiverUserId)").collection("Group_Conversion").order(by: "TimeStamp", descending: false).addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.messagesArray.removeAll()
                for document in documents {
                    let user = document.data()["UserName"] as! String
                    let message = document.data()["Message"]  as! String
                    var time = document.data()["TimeStamp"]
                    let date = Date(timeIntervalSince1970: time as! TimeInterval)
                    let dateFormmater = DateFormatter()
                    dateFormmater.dateFormat = "hh:mm a"
                    dateFormmater.amSymbol = "AM"
                    dateFormmater.pmSymbol = "PM"
                    time = dateFormmater.string(from: date)
                    let messageType = document.data()["MessageType"] as! String
                    let chat = TextChat.init(name: user,
                                             message: message,
                                             time: time as! String,
                                             type: messageType )
                    self.messagesArray.append(chat)
                }
                self.conversionTableView.reloadData()
                if self.messagesArray.count != 0 {
                    self.conversionTableView.scrollToRow(at: IndexPath(row: self.messagesArray.count - 1,section: 0),
                                                         at: .bottom,
                                                         animated: true)
                }
            }
        } else {
            AppConstants.dataBase.collection("User_Conversions").document("\(user_1)_TO_\(user_2)").collection("Conversion").order(by: "TimeStamp", descending: false).addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.messagesArray.removeAll()
                for document in documents {
                    let user = document.data()["UserName"] as! String
                    let message = document.data()["Message"]  as! String
                    var time = document.data()["TimeStamp"]
                    let date = Date(timeIntervalSince1970: time as! TimeInterval)
                    let dateFormmater = DateFormatter()
                    dateFormmater.dateFormat = "hh:mm a"
                    time = dateFormmater.string(from: date)
                    let messageType = document.data()["MessageType"] as! String
                    let chat = TextChat.init(name: user,
                                             message: message,
                                             time: time as! String,
                                             type: messageType )
                    self.messagesArray.append(chat)
                }
                self.conversionTableView.reloadData()
                if self.messagesArray.count != 0 {
                    self.conversionTableView.scrollToRow(at: IndexPath(row: self.messagesArray.count - 1, section: 0),
                                                         at: .bottom,
                                                         animated: true)
                }
            }
        }
    }
}

//MARK: - UITextFieldDelegate , Keyboard Show/Hide

extension MessageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnKey = messageTextField.text {
            sendMessages(sentMessage: returnKey, messageType: MessageType.text.rawValue)
        }
        messageTextField.resignFirstResponder()
        messageTextField.text = ""
        self.sendButton.isEnabled = false
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if messageTextField.text != "" {
            return true
        } else {
            messageTextField.placeholder = "Enter the message !!!"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        messageTextField.text = ""
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField ==  messageTextField else { return true }
        let newLength = (textField.text?.count ?? 0) - range.length + string.count
        sendButton.isEnabled = newLength > 0
        return true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint.constant = -(keyboardFrame.size.height - self.view.safeAreaInsets.bottom + 5)
            self.view.layoutIfNeeded()
        })
        
        if messagesArray.count != 0 {
            self.conversionTableView.scrollToRow(at: IndexPath(row: messagesArray.count - 1, section: 0), at: .bottom, animated: true)
        }
        print("Notification: Keyboard will show")
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 0
        self.view.frame.origin.y = 0
        print("Notification: Keyboard will hide")
    }
}

//MARK: - UITableViewDelegate

extension MessageViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        conversionTableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension MessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messagesArray[indexPath.row].name == senderUserName {
            if messagesArray[indexPath.row].type == "text" {
                let rightTextCell = conversionTableView.dequeueReusableCell(withIdentifier: "rightcell", for: indexPath) as! RightTableViewCell
                rightTextCell.configure(message: messagesArray[indexPath.row].message, time: messagesArray[indexPath.row].time)
                return rightTextCell
            } else {
                let rightImageCell = conversionTableView.dequeueReusableCell(withIdentifier: "rightimagecell", for: indexPath) as! RightImageTableViewCell
                rightImageCell.configure(message: messagesArray[indexPath.row].message, time: messagesArray[indexPath.row].time)
                return rightImageCell
            }
        } else {
            if receiverUserId.count == 15 {
                if messagesArray[indexPath.row].type == "text" {
                    let textCell = conversionTableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell
                    textCell.configure(message: messagesArray[indexPath.row].message, time: messagesArray[indexPath.row].time, name: messagesArray[indexPath.row].name)
                    return textCell
                } else {
                    let imageCell = conversionTableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
                    imageCell.configure(message: messagesArray[indexPath.row].message, time: messagesArray[indexPath.row].time, name: messagesArray[indexPath.row].name)
                    return imageCell
                }
            } else {
                if messagesArray[indexPath.row].type == "text" {
                    let leftTextCell = conversionTableView.dequeueReusableCell(withIdentifier: "leftcell", for: indexPath) as! LeftTableViewCell
                    leftTextCell.configure(message: messagesArray[indexPath.row].message, time: messagesArray[indexPath.row].time)
                    return leftTextCell
                } else {
                    let leftImageCell = conversionTableView.dequeueReusableCell(withIdentifier: "leftimagecell", for: indexPath) as! LeftImageTableViewCell
                    leftImageCell.configure(message: messagesArray[indexPath.row].message, time: messagesArray[indexPath.row].time)
                    return leftImageCell
                }
            }
        }
    }
}

//MARK: - Photo Library Image Picker

extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[.mediaType] as? String {
            if mediaType == "public.image" {
                guard let url = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
                print(url)
                uploadFile(fileURL: url)
            }
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func uploadFile (fileURL : URL) {
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "yyyy-MM-dd_hh:mm:ss_a"
        let fileName = dateFormmater.string(from: Date())
        
        let imageFile = fileURL
        let imageLocation = AppConstants.storageRef.child("\(user_1)_TO_\(user_2)").child("img_\(fileName)")
        imageLocation.putFile(from: imageFile, metadata: nil) { [weak self] (metadata, err) in
            guard metadata != nil else {
                print(err?.localizedDescription as Any)
                return
            }
            self?.downloadFile(fileName: fileName)
        }
    }
    
    func downloadFile (fileName: String) {
        let downloadRef = AppConstants.storageRef.child("\(user_1)_TO_\(user_2)").child("img_\(fileName)")
        downloadRef.downloadURL { [weak self] url, error in
            if let downloadImageUrl = url {
                let imageFileUrl = String("\(downloadImageUrl)")
                self?.sendMessages(sentMessage: imageFileUrl, messageType: MessageType.image.rawValue)
            } else {
                print(error?.localizedDescription ?? "Error occurs")
                return
            }
        }
    }
}

//MARK: - Photo Image Extension

extension UIImageView {
    func loadImage (urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

//MARK: - Add Person Delegate

extension MessageViewController: AddPersonActionDelegate {
    func actionAddPerson(newMembers: [UserDataStructure]) {
        self.addMember(addPersonList: newMembers)
    }
}

//MARK: - Remove Person Delegate

extension MessageViewController: RemovePersonActionDelegate {
    func actionRemovePerson(removeMembers: [GroupMembersData]) {
        self.removeMember(removePersonList: removeMembers)
    }
}
