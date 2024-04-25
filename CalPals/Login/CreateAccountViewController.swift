//
//  CreateAccountViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 3/17/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabaseInternal

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true

        emailField.textContentType = .emailAddress
        passwordField.textContentType = .password
        confirmPasswordField.textContentType = .password
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            // Handle empty email, password, or confirmPassword fields
            let alert = UIAlertController(title: "Error", message: "Please fill in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        if password != confirmPassword {
            // Handle password mismatch
            let alert = UIAlertController(title: "Error", message: "Passwords do not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                // Handle sign up error
                let errorMessage = error.localizedDescription
                let alert = UIAlertController(title: "Sign Up Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            // User signed up successfully
            // Perform any additional actions, such as navigating to another view controller
            self.performSegue(withIdentifier: "signUpToTabSegue", sender: self)
            
            // add the user name to firebase
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                let ref = Database.database().reference().child("users").child(uid).child("name")
                ref.setValue(email)
            }
        }
    }
}
