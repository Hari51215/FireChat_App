//  AppConstants.swift
//  Validation
//  Created by hari-pt5664 on 22/08/22.

import Foundation
import FirebaseStorage
import FirebaseFirestore

class AppConstants {
    static let dataBase = Firestore.firestore()
    static var userNames = [String]()
    static var userIds = [String]()
    static var groupNames = [String]()
    static var groupIds = [String]()
    static var userDetails = [Any]()
    static let storage = Storage.storage()
    static let storageRef = storage.reference()
    static let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
}
