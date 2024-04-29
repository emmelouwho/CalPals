//
//  GroupEventTableViewCell.swift
//  CalPals
//
//  Created by Andrea Aranda Ramos on 4/26/24.
//  Based on Mahta's EventTableViewCell for consistency.

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class GroupEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    // need the days label
    // need duration label
    

    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var locationName: UILabel!
    
    //    @IBOutlet weak var daysLabel: UILabel!
//    @IBOutlet weak var durationLabel: UILabel!
//    //RHS
//
//    @IBOutlet weak var locationName: UILabel!
    
    
    
    func configureWith(event: Event) {
        startTimeLabel.text = event.noEarlierThan
        endTimeLabel.text = event.noLaterThan
        eventName.text = event.name
        locationName.text = event.loc
        //configure the days
//        durationLabel.text = event.duration
//        daysLabel.numberOfLines = 0
//        daysLabel.text = formatDays(event: event)
    }
    
    
    private func formatDays(event: Event) -> String {
        let daysSelected = event.dayOptions.compactMap { $0.value ? $0.key : nil }
        let daysString = daysSelected.sorted(by: { $0 < $1 }).joined(separator: ", ")
        return daysString
    }
    
}
