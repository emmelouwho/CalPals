//
//  AvailabilityModel.swift
//  CalPals
//
//  Created by Emily Erwin on 3/26/24.
//

import Foundation
import FirebaseDatabaseInternal
import FirebaseDatabase
import FirebaseAuth

class AvailabilityModel {
    // each row is the list of times they are avalible
    // basically a transverse of the scheduling page
    var availability: [[Bool]] = Array(repeating: Array(repeating: false, count: 48), count: 7)
    
    func addFirebaseDataToCurrent(forUser uid: String, completion: @escaping () -> Void) {
        
        let ref = Database.database().reference().child("users").child(uid).child("availability")

        // Retrieve data
        ref.observeSingleEvent(of: .value, with: { snapshot in
            for (dayIndex, day) in days.enumerated() {
                if let dayData = snapshot.childSnapshot(forPath: day).value as? [String: Bool] {
                    for (timeIndex, time) in allTimes.enumerated() {
                        if let isAvailable = dayData[time] {
                            // Map the time to the correct index in the 2D array
                            self.availability[dayIndex][timeIndex] = isAvailable
                        }
                    }
                }
            }
            
            completion()
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func toggleHighlight(at indexPath: IndexPath, slot: Int) {
        availability[slot][indexPath.row] = !availability[slot][indexPath.row]
    }

    func highlightSlot(at indexPath: IndexPath, slot: Int) {
        availability[slot][indexPath.row] = true
    }

    func removeHighlight(at indexPath: IndexPath, slot: Int) {
        availability[slot][indexPath.row] = false
    }

    func isSlotHighlighted(at indexPath: IndexPath, slot: Int) -> Bool {
        return availability[slot][indexPath.row]
    }

    func highlightsForIndexPath(_ indexPath: IndexPath) -> Set<Int> {
        var allAvailability = Set<Int>()
        for i in 0..<7 {
            if availability[i][indexPath.row] {
                allAvailability.insert(i)
            }
        }
        return allAvailability
    }

    // Call this to reset highlights if needed
    func resetHighlights() {
        availability = Array(repeating: Array(repeating: false, count: 48), count: 7)
    }
    
    func storeDataInFireBase(forUser uid: String){
        var availabilityDict: [String: [String: Bool]] = [:]

        // format data to store
        for (dayIndex, dayAvailability) in availability.enumerated() {
            let dayName = days[dayIndex]
            var dailyAvailability: [String: Bool] = [:]
            
            for (hourIndex, isAvailable) in dayAvailability.enumerated() {
                let hourName = allTimes[hourIndex]
                dailyAvailability[hourName] = isAvailable
            }
            
            availabilityDict[dayName] = dailyAvailability
        }
        
        // store data
        let ref = Database.database().reference()
        ref.child("users").child(uid).child("availability").setValue(availabilityDict) { error, reference in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
    }
    
}
