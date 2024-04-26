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
    var eventDetails: String? = nil
    
    init() {
        
    }
    
    init(eventDict: [String: Any], eventId: String, groupId: String){
        if let name = eventDict["name"] as? String,
           let loc = eventDict["loc"] as? String,
           let group = eventDict["group"] as? String,
           let description = eventDict["description"] as? String,
           let dayOptions = eventDict["days"] as? [String: Bool],
           let noEarlierThan = eventDict["noEarlierThan"] as? String,
           let noLaterThan = eventDict["noLaterThan"] as? String,
           let duration = eventDict["duration"] as? String {
            self.id = eventId
            self.name = name
            self.loc = loc
            self.group = group
            self.groupId = groupId
            self.description = description
            self.dayOptions = dayOptions
            self.noEarlierThan = noEarlierThan
            self.noLaterThan = noLaterThan
            self.duration = duration
        }
    }
    
    init(id: String!, name: String? = nil, loc: String? = nil, group: String? = nil, groupId: String? = nil, description: String? = nil, dayOptions: [String : Bool], noEarlierThan: String, noLaterThan: String, duration: String) {
        self.id = id
        self.name = name
        self.loc = loc
        self.group = group
        self.groupId = groupId
        self.description = description
        self.dayOptions = dayOptions
        self.noEarlierThan = noEarlierThan
        self.noLaterThan = noLaterThan
        self.duration = duration
    }
    
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
        if eventDetails == nil {
            let daysOfWeek = dayOptions.filter { $0.value }.map { $0.key }.joined(separator: ", ")
            result += "\n\(daysOfWeek) for \(duration)"
        } else {
            result += "\n @ \(eventDetails ?? "")"
        }

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
    
    private func getAllAvailable(completion: @escaping ([AvailabilityModel]) -> Void) {
        let ref = Database.database().reference().child("groups").child(groupId ?? "").child("users")
        
        var allAvailability: [AvailabilityModel] = []
        let availabilityAccessQueue = DispatchQueue(label: "com.yourapp.availabilityAccessQueue", attributes: .concurrent)
            
        
        ref.observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.exists(), let usersDict = snapshot.value as? [String: String] {
                let userIds = Array(usersDict.keys)
                let dispatchGroup = DispatchGroup()
                
                for id in userIds {
                    dispatchGroup.enter()
                    let a = AvailabilityModel()
                    a.addFirebaseDataToCurrent(forUser: id) {
                        availabilityAccessQueue.async(flags: .barrier) {
                            allAvailability.append(a)
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(allAvailability)
                }
            } else {
                completion([])
            }
        }) { error in
            print("Firebase read error: \(error.localizedDescription)")
            completion([])
        }
    }
    
    func findEventTime(completion: @escaping (String?) -> Void) {
        getAllAvailable { allAvailability in
            guard let startIndex = allTimes.firstIndex(of: self.noEarlierThan),
                  let endIndex = allTimes.firstIndex(of: self.noLaterThan) else {
                completion(nil)
                return
            }
            let durationNum = self.durationInMinutes(durationString: self.duration)
            let slotsNeeded = durationNum / 30
            
            // Loop through each potential start index within the valid range
            for start in startIndex...(endIndex - slotsNeeded) {
                var isAvailableForAll = true

                // Check each day of the week
                for (day, isChecked) in self.dayOptions {
                    if isChecked, let dayIndex = days.firstIndex(of: day) {
                        // Check for each user
                        for user in allAvailability {
                            isAvailableForAll = isAvailableForAll && self.isConsecutiveAvailable(user: user, start: start, slotsNeeded: slotsNeeded, day: dayIndex)
                        }
                        
                        // If all users are available on a valid day within the time range, return the time
                        if isAvailableForAll {
                            let time = "\(allTimes[start]) on \(day)"
                            self.eventDetails = time
                            completion(time)
                            return
                        }
                    }
                }
            }
            completion(nil)
        }
    }
    
    func isConsecutiveAvailable(user: AvailabilityModel, start: Int, slotsNeeded: Int, day: Int) -> Bool {
        for i in start..<start + slotsNeeded {
            if !user.isSlotHighlighted(at: IndexPath(row: i, section: day), slot: 0) {
                return false
            }
        }
        return true
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
