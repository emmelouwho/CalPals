//
//  GroupSettingsViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 4/7/24.
//

import UIKit
import CoreData

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventTableView: UITableView!
    var currGroup:Group?
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var noEventsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupNameLabel.text = currGroup!.name
        if let image = currGroup!.image {
            groupImage.image = image
            groupImage.contentMode = .scaleAspectFill
        }
        groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
        groupImage.clipsToBounds = true
        // Do any additional setup after loading the view.
        if let groupName = currGroup?.name {
            noEventsLabel.text = "\(groupName) has no events. Go to the Add Tab to create an event."
        } else {
            noEventsLabel.text = "This group has no events. Go to the Add Tab to create an event."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupNameLabel.text = currGroup!.name
        if let image = currGroup!.image {
            groupImage.image = image
            groupImage.contentMode = .scaleAspectFill
        }
        groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
        groupImage.clipsToBounds = true
        if let groupName = currGroup?.name {
            noEventsLabel.text = "\(groupName) has no events. Go to the Add Tab to create an event."
        } else {
            noEventsLabel.text = "This group has no events. Go to the Add Tab to create an event."
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let eventsList = currGroup?.events as? [String] {
            if eventsList.isEmpty {
                noEventsLabel.isHidden = false
                return 0
            } else {
                noEventsLabel.isHidden = true
                return eventsList.count
            }
        }
        noEventsLabel.isHidden = false
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        // Check if currGroup and eventsList are not nil, and index is within bounds
        if let eventsList = currGroup?.events as? [String], indexPath.row < eventsList.count {
            let event = eventsList[indexPath.row]
            cell.textLabel?.text = event
        } else {
            cell.textLabel?.text = "Event not found"
        }
        
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
