//
//  GroupViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 4/2/24.
//

import UIKit
import CoreData
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

protocol CreateGroupDelegate : AnyObject {
    func addGroup(groupImage:UIImage, groupName: String, events:[String], groupDescription: String)->Group
}

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CreateGroupDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroupsLabel: UILabel!
    
    var groupList:[Group] = []
    var selectedCellIndexPath: IndexPath?
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        tableView.isHidden = true
        noGroupsLabel.isHidden = true
        
        retrieveGroups { groups in
            // Update the UI with the retrieved groups
            // Make sure to do this on the main thread if you're updating the UI
            DispatchQueue.main.async {
                self.groupList = groups
                if self.groupList.isEmpty {
                    self.noGroupsLabel.isHidden = false
                } else {
                    self.noGroupsLabel.isHidden = true
                }
                self.tableView.reloadData()
                self.tableView.rowHeight = 120
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                
            }
        }
        
        
        // Create a UIBarButtonItem with a plus icon
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        // Set the UIBarButtonItem as the rightBarButtonItem of the navigation item
        navigationItem.rightBarButtonItem = addButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        tableView.reloadData()
      }
    
    func addGroup(groupImage: UIImage, groupName: String, events: [String], groupDescription: String) -> Group{
        let newGroup = Group(name: groupName, description: groupDescription, image: groupImage)
        
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            newGroup.storeDataInFireBase(forUser: uid)
        }
        groupList.append(newGroup)
        if groupList.isEmpty {
            noGroupsLabel.isHidden = false
        } else {
            noGroupsLabel.isHidden = true
        }
        tableView.reloadData()
        return newGroup
    }

    func retrieveGroups(completion: @escaping ([Group]) -> Void) {
        var groups: [Group] = []
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let ref = Database.database().reference().child("users").child(uid).child("groups")
            // we are getting all the group ids listed under the current user
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists(), let groupsDict = snapshot.value as? [String: Any] {
                    let groupIds = Array(groupsDict.keys)
                    let dispatchGroup = DispatchGroup()
                    
                    // for each group, get all the infomation
                    for id in groupIds {
                        dispatchGroup.enter()
                        let groupRef = Database.database().reference().child("groups").child(id)
                        // get that groups info from firebase
                        groupRef.observeSingleEvent(of: .value, with: { snapshot in
                            if snapshot.exists(), let groupDict = snapshot.value as? [String: Any] {
                                // now we are getting the group's image from storage
                                let imageRef = Storage.storage().reference().child("images/\(id).jpg")
                                dispatchGroup.enter()
                                imageRef.downloadURL { result in
                                    switch result {
                                    case .success(let url):
                                        // Download the image data
                                        URLSession.shared.dataTask(with: url) { data, response, error in
                                            var image: UIImage? = nil
                                            if let data = data {
                                                image = UIImage(data: data)
                                            }
                                            // Create the group once the image is downloaded
                                            let newGroup = Group(
                                                name: groupDict["name"] as? String,
                                                description: groupDict["description"] as? String,
                                                image: image,
                                                id: id
                                            )
                                            groups.append(newGroup)
                                            dispatchGroup.leave() // Leave after processing image
                                        }.resume() // Start the download task
                                    case .failure(let error):
                                        // Handle error or no URL case
                                        let newGroup = Group(
                                            name: groupDict["name"] as? String ?? "Unknown",
                                            description: groupDict["description"] as? String ?? "",
                                            image: nil,
                                            id: id
                                        )
                                        groups.append(newGroup)
                                        dispatchGroup.leave()
                                    }
                                }
                            } else {
                                print("Group not found")
                            }
                            // Leave group after fetching group details
                            dispatchGroup.leave()
                        })
                    }
                    
                    // Call the completion handler once all group details and images have been fetched
                    dispatchGroup.notify(queue: .main) {
                        completion(groups)
                    }
                } else {
                    print("No groups found for this user.")
                    completion([]) // Return an empty array if no groups are found
                }
            })
        } else {
            completion([]) // Return an empty array if no user is logged in
        }
    }

    @objc func addButtonTapped() {
        // Perform segue to the destination view controller
        performSegue(withIdentifier: "CreateGroupSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        let group = groupList[indexPath.row]
        cell.textLabel?.text = group.name
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75)) // Adjust the frame as needed
//            if let imageData = group.groupImage, let image = UIImage(data: imageData) {
//                imageView.image = image
//            }
        imageView.image = group.image
            imageView.layer.cornerRadius = imageView.frame.width / 2 // Make it a circle
            imageView.clipsToBounds = true // Clip to bounds
            cell.accessoryView = imageView // Set the image view as the accessory view of the cell
            return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: fix
            //context.delete(groupList[indexPath.row])
            groupList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
            if groupList.isEmpty {
                noGroupsLabel.isHidden = false
            } else {
                noGroupsLabel.isHidden = true
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGroup = groupList[indexPath.row] // Assuming groupList is your array of GroupEntity objects
         performSegue(withIdentifier: "showGroupSettingsSegue", sender: selectedGroup)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
            let destination = segue.destination as? CreateGroupViewController
        {
            destination.delegate = self
        } else if segue.identifier == "showGroupSettingsSegue",
            let selectedGroup = sender as? Group,
            let destination = segue.destination as? GroupSettingsViewController {
            destination.currGroup = selectedGroup
        }
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
