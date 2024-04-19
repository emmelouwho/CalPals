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

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsLabel: UILabel!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let event = events[indexPath.row]
        cell.textLabel?.text = event.name
        return cell
    }

}
