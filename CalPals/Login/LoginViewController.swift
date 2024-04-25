//
//  LoginViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 3/17/24.
//

import UIKit
import FirebaseAuth
import CoreData

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordField.isSecureTextEntry = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if a user is already logged in
        isUserLoggedIn { isLoggedIn in
            if isLoggedIn {
                // User is logged in, perform segue or other actions
                self.performSegue(withIdentifier: "loginToTabSegue", sender: self)
            } else {
                // User is not logged in, handle accordingly
            }
        }
        emailField.text! = ""
        passwordField.text! = ""
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty else {
            // Handle empty email or password fields
                let alert = UIAlertController(title: "Login Error", message: "Email and password are required.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }

            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                    
                if let error = error {
                    // Handle login error
                    let errorMessage = error.localizedDescription
                    let alert = UIAlertController(title: "Login Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                    
                // Update email and password in Core Data
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                do {
                    let user = try context.fetch(fetchRequest).first ?? User(context: context)
                    user.email = email
                    user.password = password
                    try context.save()
                } catch {
                    print("Failed to update email and password: \(error)")
                }
                // Perform segue only if login was successful
                self.performSegue(withIdentifier: "loginToTabSegue", sender: self)
                }
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCreatePageSegue", sender: self)
    }
    
    func isUserLoggedIn(completion: @escaping (Bool) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                guard let email = user.email, !email.isEmpty,
                      let password = user.password, !password.isEmpty else {
                    completion(false)
                    return
                }
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print("Failed to sign in with email and password: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else {
                completion(false)
            }
        } catch {
            print("Failed to fetch user: \(error)")
            completion(false)
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
