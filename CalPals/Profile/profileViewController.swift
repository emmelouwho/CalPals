//
//  profileViewController.swift
//  CalPals
//
//  Created by Mahta Ghotbi on 4/8/24.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseStorage
import FirebaseFirestore
import FirebaseDatabaseInternal

var globalProfileImage: UIImage?

class profileViewController: UIViewController {

    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var emailLabel: UILabel!
    //@IBOutlet var groupNumberLabel: UILabel!
    @IBOutlet var memberSinceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayUserEmail()
        displayCreationDate()
        
        profilePhoto.image = UIImage(named: "person")
        displayProfileImage()
                
        let size = min(profilePhoto.frame.size.width, profilePhoto.frame.size.height)
        profilePhoto.frame = CGRect(x: profilePhoto.frame.origin.x, y: profilePhoto.frame.origin.y, width: size, height: size)
        profilePhoto.layer.cornerRadius = size / 2
        profilePhoto.clipsToBounds = true
        profilePhoto.contentMode = .scaleAspectFill
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          fetchUsername()
    }
    
    
    func fetchUsername() {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let ref = Database.database().reference().child("users").child(uid).child("name")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists(), let name = snapshot.value as? String {
                    self.userName.text = name
                }
            })
        }
    }
    
    
    func displayUserEmail() {
        let defaultEmail = "No Email Available"
        let email = fetchCurrentUserEmail() ?? defaultEmail
        emailLabel.text = "Email: \(email)"
        
       }
    
    func fetchCurrentUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }
    
    func displayCreationDate() {
            let defaultDate = "Date Not Available"
            let creationDate = fetchAccountCreationDate() ?? defaultDate
            memberSinceLabel.text = "Member since: \(creationDate)"
        }
    
    func fetchAccountCreationDate() -> String? {
        if let creationDate = Auth.auth().currentUser?.metadata.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: creationDate)
        }
        return nil
    }
    

    //profile photo stuff
    func displayProfileImage() {
        let userID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")
        storageRef.downloadURL { [weak self] url, error in
            guard let self = self else { return }
            if let url = url {
                self.loadImageFromURL(url.absoluteString)
            } else if let error = error {
                print("Error getting download URL: \(error.localizedDescription)")
            }
        }
        
    }
    
    //get image from URL
    func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
                   print("Invalid URL string.")
                   return
               }
               URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to download image data: \(error)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Bad HTTP response or error")
                    return
                }
                guard let data = data else {
                    print("No image data found.")
                    return
                }
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                    self.profilePhoto.image = image
                    globalProfileImage = image
                    } else {
                        print("Failed to create image from data.")
                    }
                }
            }.resume()
    }
    
    
    func uploadImageToFirebase(image: UIImage) {
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
            let userID = Auth.auth().currentUser?.uid ?? "defaultUserID"
            let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")

            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        print("Download URL: \(downloadURL.absoluteString)")
                    } else if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    //edit pressed
    @IBAction func editPfpPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            // Sign out the user from Firebase
            try Auth.auth().signOut()
            
            // Delete the user from Core Data
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            if let user = try context.fetch(fetchRequest).first {
                context.delete(user)
                try context.save()
            }
            
            // Dismiss the current view controller and go back to LoginViewController
            self.dismiss(animated: true) {
                if let navController = self.navigationController {
                    for controller in navController.viewControllers {
                        if let loginViewController = controller as? LoginViewController {
                            navController.popToViewController(loginViewController, animated: true)
                            break
                        }
                    }
                }
            }
        } catch {
            print("Sign-out error: \(error)")
        }
    }
}

extension profileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profilePhoto.image = selectedImage
        uploadImageToFirebase(image: selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



