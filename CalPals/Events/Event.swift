//
//  Event.swift
//  CalPals
//
//  Created by Emily Erwin on 3/18/24.
//

import Foundation
import FirebaseDatabaseInternal

class Event {
    var id: String!
    var name: String?
    var loc: String?
    var group: String?
    var groupId: String?
    var description: String?
    
    var dayOptions: [String: Bool] = [
        "Sun": false, "Mon": false, "Tue": false, "Wed": false, "Thu": false, "Fri": false, "Sat": false
    ]
    
    var noEarlierThan: String = "12AM"
    var noLaterThan: String = "11PM"
    
    var duration: String = "30 min"
    
    func setBasic(name: String?, location: String?, group: String?, description: String?, repeats: String? = "Never", duration: String){
        self.name = name
        self.loc = location == "Location" ? "" : location
        self.group = group
        self.description = description
        self.duration = duration
        self.id = generateRandomID(length: 8)
    }
    
    func setDays(mon: Bool, tue: Bool, wed: Bool, thu: Bool, fri: Bool, sat: Bool, sun: Bool) {
        dayOptions = [
            "Sun": sun,
            "Mon": mon,
            "Tue": tue,
            "Wed": wed,
            "Thu": thu,
            "Fri": fri,
            "Sat": sat
        ]
    }
    
    func validateEvent() -> String{
        if name == nil {
            return "Event must have a name"
        }
        if group == nil {
            return "Must select a group. If you have no groups to choose from, please create a group."
        }
        if let startIndex = allTimes.firstIndex(of: noEarlierThan),
           let endIndex = allTimes.firstIndex(of: noLaterThan) {
            if startIndex > endIndex {
                return "No later than time must be before no earlier time"
            }
        }
        let hasOneDaySelected = dayOptions.contains { $0.value == true }
        if !hasOneDaySelected {
            return "Must choose at least one day"
        }
        
        let doesFit = doesDurationFit(noEarlierThan: noEarlierThan, noLaterThan: noLaterThan, durationString: duration)
        if !doesFit {
            return "The amount of time between no earlier than time and no later time must be long enough to fit the duration"
        }
        
        return ""
    }
    
    func eventCreatedMessage() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        
        var result = "\(name ?? "")"
        if loc != "" && loc != nil {
            result += " @ \(loc ?? "")"
        }
        let daysOfWeek = dayOptions.filter { $0.value }.map { $0.key }.joined(separator: ", ")
        result += "\n\(daysOfWeek) for \(duration)"
        
        return result
    }
    
    // Calculate duration in minutes
    func durationInMinutes(durationString: String) -> Int {
        let parts = durationString.split(separator: " ")
        var minutes = 0
        for i in 0..<parts.count {
            if parts[i].contains("hr") {
                if let hours = Int(parts[i-1]) {
                    minutes += hours * 60
                }
            } else if parts[i].contains("min") {
                if let mins = Int(parts[i-1]) {
                    minutes += mins
                }
            }
        }
        return minutes
    }

    // Check if the duration fits between two times
    func doesDurationFit(noEarlierThan: String, noLaterThan: String, durationString: String) -> Bool {
        guard let startIndex = allTimes.firstIndex(of: noEarlierThan),
              let endIndex = allTimes.firstIndex(of: noLaterThan) else {
            return false
        }

        let duration = durationInMinutes(durationString: durationString)
        // Calculate the end index based on duration
        let durationIndexSteps = duration / 30

        // Check if adding the duration goes beyond noLaterThan
        return startIndex + durationIndexSteps <= endIndex
    }
    
    func storeDataInFireBase(for uid: String){
        let eventDict = [
            "name": name,
            "loc": loc,
            "description": description,
            "group": group,
            "days": dayOptions,
            "noEarlierThan": noEarlierThan,
            "noLaterThan": noLaterThan,
            "duration": duration,
        ] as [String : Any]
        
        let ref = Database.database().reference()
        ref.child("groups").child(groupId!).child("events").child(id).setValue(eventDict){ error, reference in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
    }

}
