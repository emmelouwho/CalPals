//
//  editUsernameViewController.swift
//  CalPals
//
//  Created by Mahta Ghotbi on 4/8/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class editUsernameViewController: UIViewController {


    @IBOutlet var userNameField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func savePressed(_ sender: Any) {
        guard let newUsername = userNameField.text, !newUsername.isEmpty else {
            print("Username field is empty.")
            return
        }
        updateUsername(newUsername)
    }
    
    
    private func updateUsername(_ username: String) {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not logged in")
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document(userID).setData(["username": username], merge: true) { [weak self] error in
                if let error = error {
                    print("Error updating username: \(error.localizedDescription)")
                } else {
                    print("Username successfully updated.")
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
