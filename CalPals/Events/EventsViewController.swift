//
//  EventsViewController.swift
//  CalPals
//
//  Created by Emily Erwin on 4/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabaseInternal
import FirebaseStorage
import FirebaseFirestore

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    var events: [Event] = []
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        tableView.isHidden = true
        
        fetchProfileImage()
        fetchUsername()
        retrieveEvents{ events in
            DispatchQueue.main.async {
                self.events = events
                if self.events.isEmpty {
                    self.noEventsLabel.isHidden = false
                } else {
                    self.noEventsLabel.isHidden = true
                }
                self.tableView.reloadData()
                self.tableView.rowHeight = 120
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
            }
        }
    }
    
    func fetchUsername() {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let ref = Database.database().reference().child("users").child(uid).child("name")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists(), let name = snapshot.value as? String {
                    self.usernameLabel.text = name
                }
            })
        }
    }
    
    
    func fetchProfileImage() {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let ref = Database.database().reference().child("users").child(uid).child("profileImageUrl")
            ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if let imageUrl = snapshot.value as? String, let url = URL(string: imageUrl) {
                    self?.downloadImage(url: url)
                }
            })
        }
    }

    func downloadImage(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profilePicture.image = image
                }
            }
        }.resume()
    }
    
    
   

    
    func retrieveEvents(completion: @escaping ([Event]) -> Void) {
            var events: [Event] = []
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                let ref = Database.database().reference().child("users").child(uid).child("groups")
                
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if let groupsDict = snapshot.value as? [String: Any] {
                        let groupIds = Array(groupsDict.keys)
                        let dispatchGroup = DispatchGroup()
                        
                        for id in groupIds {
                            dispatchGroup.enter()
                            let groupRef = Database.database().reference().child("groups").child(id).child("events")
                            
                            groupRef.observeSingleEvent(of: .value, with: { snapshot in
                                if let eventsDict = snapshot.value as? [String: [String: Any]] {
                                    for (key, value) in eventsDict {
                                        let newEvent = Event(eventDict: value, eventId: key, groupId: id)
                                        // check eveything got set right
                                        if newEvent.id == key{
                                            events.append(newEvent)
                                        }
                                    }
                                }
                                dispatchGroup.leave()
                            })
                        }
                        dispatchGroup.notify(queue: .main) {
                            completion(events)
                        }
                    } else {
                        completion([]) // No groups found
                    }
                })
            } else {
                completion([]) // No user logged in
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventTableViewCell else {
                   return UITableViewCell() // Return an empty cell if something fails
        }
        let event = events[indexPath.row]
        cell.configureWith(event: event)
        return cell
    }

}
