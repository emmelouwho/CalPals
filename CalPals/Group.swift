//
//  Group.swift
//  CalPals
//
//  Created by Emily Erwin on 4/8/24.
//

import Foundation
import UIKit
import FirebaseDatabaseInternal


class Group {
    var id: String!
    var name: String!
    var description: String!
    var image: UIImage!
    var events: [Event] = []
    
    init(name: String!, description: String!, image: UIImage!, id: String? = nil) {
        self.id = id == nil ? generateRandomID(length: 8) : id
        self.name = name
        self.description = description
        self.image = image
    }
    
    func generateRandomID(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap{ _ in characters.randomElement() })
    }
    
    func storeDataInFireBase(forUser uid: String){
        var groupDict = ["name": name, "description": description]
        let ref = Database.database().reference()
        
        // storing all group data in the groups tab
        ref.child("groups").child(id).setValue(groupDict){ error, reference in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
        
        // storing group name in the users tab
        ref.child("users").child(uid).child("groups").child(id).setValue(name){ error, reference in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
    }
}
