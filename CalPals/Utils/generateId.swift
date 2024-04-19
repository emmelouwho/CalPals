//
//  generateId.swift
//  CalPals
//
//  Created by Emily Erwin on 4/18/24.
//

import Foundation

func generateRandomID(length: Int) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).compactMap{ _ in characters.randomElement() })
}
