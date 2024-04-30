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
   

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    var events: [Event] = []
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchUsername()
        retrieveEvents { events in
            self.events = events
            self.updateUIPostEventRetrieval()
        }
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
           activityIndicator = UIActivityIndicatorView(style: .large)
           activityIndicator.center = self.view.center
           self.view.addSubview(activityIndicator)
           activityIndicator.startAnimating()
           tableView.isHidden = true
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
    
    func retrieveEvents(completion: @escaping ([Event]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            self.noEventsLabel.isHidden = false
            return
        }
        let uid = user.uid
        let ref = Database.database().reference().child("users").child(uid).child("groups")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let groupsDict = snapshot.value as? [String: Any] else {
                self.noEventsLabel.isHidden = false
                return
            }
            self.processGroups(groupsDict)
        }
    }
    
    private func processGroups(_ groupsDict: [String: Any]) {
        var events: [Event] = []
        let groupIds = Array(groupsDict.keys)
        let dispatchGroup = DispatchGroup()
        
        for id in groupIds {
            dispatchGroup.enter()
            let groupRef = Database.database().reference().child("groups").child(id).child("events")
            groupRef.observeSingleEvent(of: .value) { snapshot in
                if let eventsDict = snapshot.value as? [String: [String: Any]] {
                    events.append(contentsOf: eventsDict.map { Event(eventDict: $1, eventId: $0, groupId: id) })
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.events = events
            self.updateUIPostEventRetrieval()
        }
    }
    
    private func updateUIPostEventRetrieval() {
           self.noEventsLabel.isHidden = !self.events.isEmpty
           self.tableView.reloadData()
           self.tableView.rowHeight = 120
           self.activityIndicator.stopAnimating()
           self.tableView.isHidden = self.events.isEmpty
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
     
    //Delete event
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventToDelete = events[indexPath.row]
            let alert = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteEvent(event: eventToDelete, indexPath: indexPath)
            }))
            present(alert, animated: true)
        }
    }
    
    //delete the event functionally
    func deleteEvent(event: Event, indexPath: IndexPath) {
        //grab the user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let eventRef = Database.database().reference().child("users").child(uid).child("groups").child(event.groupId!).child("events").child(event.id)

        // Remove event from Firebase
        eventRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
                return
            }
            
            // Update local data source
            self.events.remove(at: indexPath.row)

            // Update the table view
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                if self.events.isEmpty {
                    self.noEventsLabel.isHidden = false
                }
            }
        }
    }
}
