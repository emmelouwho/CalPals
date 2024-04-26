//
//  EventTableViewCell.swift
//  CalPals
//
//  Created by Mahta Ghotbi on 4/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EventTableViewCell: UITableViewCell {
    //LHS
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    //@IBOutlet weak var dateLabel: UILabel!

    //RHS
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var locationName: UILabel!
    
    func configureWith(event: Event) {
        startTimeLabel.text = event.noEarlierThan
        endTimeLabel.text = event.noLaterThan
       // dateLabel.text = ""
        eventName.text = event.name
        groupNameLabel.text = event.group
        locationName.text = event.loc
    }
    
}
