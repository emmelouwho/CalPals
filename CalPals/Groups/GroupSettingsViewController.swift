//
//  GroupSettingsViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 4/7/24.
//

import UIKit
import CoreData
import FirebaseDatabaseInternal

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventTableView: UITableView!
    var currGroup:Group?
    var events: [Event] = []
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var noEventsLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        eventTableView.dataSource = self
        eventTableView.delegate = self
        
        // group image set up
        groupNameLabel.text = currGroup!.name
        if let image = currGroup!.image {
            groupImage.image = image
            groupImage.contentMode = .scaleAspectFill
        }
        groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
        groupImage.clipsToBounds = true
        
        // handling event label
        noEventsLabel.isHidden = true

        if let groupName = currGroup?.name {
            noEventsLabel.text = "\(groupName) has no events. Go to the Add Tab to create an event."
        } else {
            noEventsLabel.text = "This group has no events. Go to the Add Tab to create an event."
        }
        
        // call retrieveEvents function to fetch events for the current group
        if let groupID = currGroup?.id {
            retrieveEvents(forGroup: groupID) { [weak self] events in
                DispatchQueue.main.async {
                    self?.currGroup?.events = events
                    if events.isEmpty {
                        self?.noEventsLabel.isHidden = false
                    } else {
                        self?.noEventsLabel.isHidden = true
                    }
                    self?.eventTableView.reloadData()
                    self?.eventTableView.rowHeight = 120
                }
            }
        }
    }
    
    func retrieveEvents(forGroup groupID: String, completion: @escaping ([Event]) -> Void) {
        let ref = Database.database().reference().child("groups").child(groupID).child("events")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let eventsDict = snapshot.value as? [String: [String: Any]] {
                for (key, value) in eventsDict {
                    let newEvent = Event(eventDict: value, eventId: key, groupId: groupID)
                    if !self.events.contains(where: {$0.id == newEvent.id}) {
                        self.events.append(newEvent)
                    }
                }
            }
            completion(self.events)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupEventCell", for: indexPath) as? GroupEventTableViewCell else {
                   return UITableViewCell() // Return an empty cell if something fails
        }
        let event = events[indexPath.row]
        cell.configureWith(event: event)
        return cell
    }
    
    @IBAction func updateGroupButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "updateGroupSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateGroupSegue",
           let destination = segue.destination as? UpdateGroupViewController
        {
            destination.currGroup = currGroup
        } else if segue.identifier == "inviteGroupSegue",let destination = segue.destination as? InviteToGroupViewController {
            destination.currGroup = currGroup
        }
    }
}
