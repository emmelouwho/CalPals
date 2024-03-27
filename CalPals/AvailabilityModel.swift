//
//  AvailabilityModel.swift
//  CalPals
//
//  Created by Emily Erwin on 3/26/24.
//

import Foundation

class AvailabilityModel {
    // each row is the list of times they are avalible
    // basically a transverse of the scheduling page
    private var availability: [[Bool]] = Array(repeating: Array(repeating: false, count: 48), count: 7)
    
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
}
