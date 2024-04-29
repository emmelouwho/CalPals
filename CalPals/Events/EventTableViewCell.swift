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
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    //RHS
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var locationName: UILabel!
    
    func configureWith(event: Event) {
        startTimeLabel.text = event.noEarlierThan
        endTimeLabel.text = event.noLaterThan
        eventName.text = event.name
        groupNameLabel.text = event.group
        locationName.text = event.loc
        //configure the days
        durationLabel.text = event.duration
        daysLabel.numberOfLines = 0
        daysLabel.text = formatDays(event: event)
    }
    
    
    private func formatDays(event: Event) -> String {
        let daysSelected = event.dayOptions.compactMap { $0.value ? $0.key : nil }
        let daysString = daysSelected.sorted(by: { $0 < $1 }).joined(separator: ", ")
        return daysString
    }
    
}
