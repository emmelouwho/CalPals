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
        if isUserLoggedIn() {
            self.performSegue(withIdentifier: "loginToTabSegue", sender: self)
        }
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
            
            // Update isLoggedIn attribute in Core Data
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            do {
                let user = try context.fetch(fetchRequest).first ?? User(context: context)
                user.email = email
                user.isLoggedIn = true
                try context.save()
            } catch {
                print("Failed to update isLoggedIn attribute: \(error)")
            }

            // Perform segue only if login was successful
            self.performSegue(withIdentifier: "loginToTabSegue", sender: self)
        }
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCreatePageSegue", sender: self)
    }
    
    func isUserLoggedIn() -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "isLoggedIn == true")
        do {
            let users = try context.fetch(fetchRequest)
            return !users.isEmpty
        } catch {
            print("Failed to fetch user: \(error)")
            return false
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
