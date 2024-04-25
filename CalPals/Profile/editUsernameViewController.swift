//
//  editUsernameViewController.swift
//  CalPals
//
//  Created by Mahta Ghotbi on 4/8/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabaseInternal

class editUsernameViewController: UIViewController {

    @IBOutlet var userNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let newUsername = userNameField.text, !newUsername.isEmpty else {
            print("Username field is empty.")
            return
        }
        updateUsername(newUsername)
    }
    
    private func updateUsername(_ username: String) {
        let ref = Database.database().reference()
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let ref = Database.database().reference().child("users").child(uid)
            
            ref.child("name").setValue(username) { error, reference in
                if let error = error {
                    print("Error updating username: \(error.localizedDescription)")
                } else {
                    print("Username successfully updated.")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
