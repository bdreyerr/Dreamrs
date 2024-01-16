//
//  WelcomeSurveyManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/15/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class WelcomeSurveyManager : ObservableObject {
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var handle: String = ""
    @Published var userColor: String = ""
    
    @Published var errorString: String = ""
    
    @Published var hasUserCompletedSurvey = true
    
    // Firestore
    let db = Firestore.firestore()
    
    var colorOptions = ["Black", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"]
    
    init() {
        self.userColor = colorOptions[0]
    }
    
    func completeWelcomeSurvey() {
        // Blank error cases
        if self.firstName == "" {
            self.errorString = "Please enter a first name"
            return
        }
        if self.lastName == "" {
            self.errorString = "Please enter a last name"
            return
        }
        if self.handle == "" {
            self.errorString = "Please enter a handle"
            return
        }
        
        // Whitespace error cases
        if self.firstName.contains(where: { $0.isWhitespace }) {
            self.errorString = "First Name must not contain a whitespace"
            return
        }
        if self.lastName.contains(where: { $0.isWhitespace }) {
            self.errorString = "Last Name must not contain a whitespace"
            return
        }
        if self.handle.contains(where: { $0.isWhitespace }) {
            self.errorString = "Handle must not contain a whitespace"
            return
        }
        
        // Character count error cases
        if self.firstName.count > 30 {
            self.errorString = "First name is too long"
            return
        }
        if self.lastName.count > 30 {
            self.errorString = "Last name is too long"
            return
        }
        if self.handle.count > 30 {
            self.errorString = "Handle is too long"
            return
        }
        
        // Get user Id from firebase Auth
        let userId = Auth.auth().currentUser!.uid
        
        // All fields are valid, update database and set UserDefault
        self.db.collection("users").document(userId).updateData([
            "firstName": self.firstName,
            "lastName": self.lastName,
            "handle": self.handle,
            "userColor": self.userColor,
            "hasUserCompletedWelcomeSurvey": true
        ]) { err in
            if let err = err {
                print("Error updating user fields from welcome sruvey: \(err)")
            } else {
                print("User updated successfully during welcome survey!")
            }
        }
    }
    
    func convertColorStringToView() -> Color {
        switch self.userColor {
        case "Black":
            return Color.black
        case "Red":
            return Color.red
        case "Blue":
            return Color.blue
        case "Green":
            return Color.green
        case "Purple":
            return Color.purple
        case "Cyan":
            return Color.cyan
        case "Yellow":
            return Color.yellow
        case "Orange":
            return Color.orange
        default:
            return Color.red
        }
    }
}
