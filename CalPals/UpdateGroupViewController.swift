//
//  UpdateGroupViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 4/8/24.
//

import UIKit

class UpdateGroupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var currGroup:Group?
    @IBOutlet weak var groupNameTitle: UILabel!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var groupDescField: UITextField!
    @IBOutlet weak var groupImageField: UIImageView!
    var groupName:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        groupName = currGroup!.name
        // Do any additional setup after loading the view.
        groupNameField.delegate = self
        groupDescField.delegate = self
        groupNameField.text = groupName
        groupImageField.layer.cornerRadius = groupImageField.frame.size.width / 2
        groupImageField.clipsToBounds = true
        if let image = currGroup!.image {
            groupImageField.image = image
            groupImageField.contentMode = .scaleAspectFill
        }
        groupNameField.text = currGroup!.name
        groupDescField.text = currGroup!.description
        
    }
    

    @IBAction func uploadPictureButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func updateGroupButtonPressed(_ sender: Any) {
        guard let groupName = groupNameField.text, let groupDesc = groupDescField.text, let groupImage = groupImageField.image, let currGroup = currGroup else { return } // Update the properties of the currGroup object
            currGroup.name = groupName
            currGroup.description = groupDesc
            // Assuming groupImage is stored as Data in the groupImageField
            currGroup.image = groupImage
            // Save the changes to the context
            do {
                //try currGroup.managedObjectContext?.save()
                let controller = UIAlertController(title: "Group saved", message: "Updated a group titled '\(groupName)' with description '\(groupDesc)'", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                present(controller, animated: true)
                // Dismiss or navigate to another screen
                performSegue(withIdentifier: "backToGroupSettingsSegue", sender: self)
            } catch {
                // Handle the error
                print("Error saving group: \(error.localizedDescription)")
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToGroupSettingsSegue",
            let destination = segue.destination as? GroupSettingsViewController
        {
            destination.currGroup = currGroup
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            groupImageField.image = pickedImage
            groupImageField.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == groupNameField {
            groupNameTitle.text = textField.text
        }
    }


    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */

}
