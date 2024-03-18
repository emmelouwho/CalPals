//
//  Event.swift
//  CalPals
//
//  Created by Emily Erwin on 3/18/24.
//

import Foundation

let repeatOptions = ["Never", "Once a Week", "Once a Month", "Annualy"]

class Event {
    var name: String?
    var loc: String?
    var group: String?
    var description: String?
    
    var startDate = Date()
    var endDate = Date()
    
    var noEarlierThan = Date()
    var noLaterThan = Date()
    
    var duration = 0
    var repeats = "Never"
    
    func setBasic(name: String?, location: String?, group: String?, description: String?, repeats: String? = "Never", duration: String){
        self.name = name
        self.loc = location
        self.group = group
        self.description = description
        self.duration = Int(duration) ?? 0
        self.repeats = repeats ?? "Never"
    }
    
    func validateEvent() -> String{
        if name == nil {
            return "Event must have a name"
        }
        if group == nil {
            return "Must select a group. If you have no groups to choose from, please create a group."
        }
        if startDate > endDate {
            return "Start date must be before end date"
        }
        if noEarlierThan > noLaterThan {
            return "No later than time must be before no earlier time"
        }
        if duration <= 0 {
            return "Duration must be greater than 0 and must be a whole number"
        }
        
        let difference = Calendar.current.dateComponents([.minute], from: noEarlierThan, to: noLaterThan).minute ?? 0
        if difference < duration {
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
        result += "\n\(formatter.string(from: startDate)) - \(formatter.string(from: endDate)) for \(duration) minutes"
        
        return result
    }
}
