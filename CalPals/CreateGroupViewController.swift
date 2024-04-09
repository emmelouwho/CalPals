//
//  CreateGroupViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 4/2/24.
//

import UIKit
import CoreData

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var groupNameTitle: UILabel!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var groupImageField: UIImageView!
    @IBOutlet weak var groupDescField: UITextField!
    var groupName: String = ""
    var group: NSManagedObject?
    
    var delegate: CreateGroupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupNameField.delegate = self
        groupDescField.delegate = self
        
        // Make the groupImageField circular
        groupImageField.layer.cornerRadius = groupImageField.frame.size.width / 2
        groupImageField.clipsToBounds = true
    }
    
    @IBAction func uploadPictureButtonPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
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
    
    @IBAction func CreateGroupButtonPressed(_ sender: Any) {
        guard let groupName = groupNameField.text,
                      let groupDesc = groupDescField.text,
                      let groupImage = groupImageField.image else {
                    return
                }
            group = (delegate?.addGroup(groupImage: groupImage, groupName: groupName, events: [String](), groupDescription: groupDesc))!
                let controller = UIAlertController(
                title: "Group saved",
                message: "Created a group titled '\(groupName)' with description '\(groupDesc)'", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                present(controller, animated: true)
                // Dismiss or navigate to another screen
                performSegue(withIdentifier: "goToGroupSettingsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGroupSettingsSegue",
            let destination = segue.destination as? GroupSettingsViewController
        {
            destination.currGroup = group as? GroupEntity
        }
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
}
