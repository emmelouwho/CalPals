//
//  Group.swift
//  CalPals
//
//  Created by Emily Erwin on 4/8/24.
//

import Foundation
import UIKit
import FirebaseDatabaseInternal
import FirebaseStorage


class Group {
    var id: String!
    var name: String!
    var description: String!
    var image: UIImage!
    var events: [Event] = []
    
    init(name: String!, description: String!, image: UIImage?, id: String? = nil) {
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
        let groupDict = ["name": name, "description": description]
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
        
        // storing image in storage
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error: Could not convert UIImage to Data")
            return
        }
        let imageRef = Storage.storage().reference().child("images/\(id ?? "1").jpg")
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error occurred: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
        }
    }
}
