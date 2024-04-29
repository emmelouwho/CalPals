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
    
    @IBOutlet weak var changePassField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changePassField.isSecureTextEntry = true
        confirmPassField.isSecureTextEntry = true
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
    
    
    @IBAction func changeButtonPressed(_ sender: Any) {
        updatePassword()
    }
    
    private func updatePassword() {
            guard let newPassword = changePassField.text, !newPassword.isEmpty, let confirmPassword = confirmPassField.text, !confirmPassword.isEmpty else {
                print("Password fields cannot be empty.")
                return
            }
            
            guard newPassword == confirmPassword else {
                print("Passwords do not match.")
                return
            }

            if newPassword.count < 6 {
                print("Password must be at least 6 characters long.")
                return
            }

            if let user = Auth.auth().currentUser {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        print("Error updating password: \(error.localizedDescription)")
                    } else {
                        print("Password successfully updated.")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    
}
