//
//  InviteToGroupViewController.swift
//  CalPals
//
//  Created by Emily Erwin on 4/22/24.
//

import UIKit
import FirebaseDatabaseInternal
import MapKit

class InviteToGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var activityIndicator: UIActivityIndicatorView!
    var allUsers: [UserInfo] = []
    var filteredUsers: [UserInfo] = []
    var currGroup: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        tableView.isHidden = true
        
        retrieveUsers { users in
            self.allUsers = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false  // Make sure the tableView is visible after loading data
            }
        }
        tableView.reloadData()
    }
    
    // MARK: firebase handling
    func retrieveUsers(completion: @escaping ([UserInfo]) -> Void) {
        var users: [UserInfo] = []
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists(), let usersDict = snapshot.value as? [String: [String: Any]] {
                for (key, value) in usersDict {
                    if let username = value["name"] as? String {
                        let newUser = UserInfo(name: username, id: key)
                        users.append(newUser)
                    }
                }
                completion(users)
            } else {
                completion([])
            }
        })

    }
    
    // MARK: search bar handling
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       filteredUsers = allUsers.filter { user in
            // Check if the user's name contains the search text
            let matchesName = user.name.lowercased().contains(searchText.lowercased())

            // check that the user is not already in the group
            let isNotInGroup = !currGroup.users.contains { groupUser in
                groupUser.id == user.id
            }
            return matchesName && isNotInGroup
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredUsers = allUsers
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    // MARK: table handling
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = filteredUsers[indexPath.row]
        
        // add to the user to it's group firebase
        let ref = Database.database().reference()
        ref.child("groups").child(currGroup.id).child("users").child(selectedUser.id).setValue(selectedUser.name) { error, reference in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
        
        // add group data under the user
        ref.child("users").child(selectedUser.id).child("groups").child(currGroup.id).setValue(currGroup.name){ error, reference in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
        
        // close this page
        dismiss(animated: true, completion: nil)
    }
    
}
