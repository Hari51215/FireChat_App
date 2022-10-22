//  SignOutViewController.swift
//  Validation
//  Created by hari-pt5664 on 10/09/22.

import UIKit

//MARK: - User Sign-Out Class

class SignOutViewController: UIViewController {
    weak var actionDelegate: SignOutActionDelegate?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.setTitle("Close", for: .normal)
        self.signoutButton.setTitle("Sign Out", for: .normal)
    }

    @IBAction private func handleCloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction private func handleSignoutTapped(_ sender: Any) {
        self.dismiss(animated: true)
        self.actionDelegate?.actionSignedOut()
    }
}
