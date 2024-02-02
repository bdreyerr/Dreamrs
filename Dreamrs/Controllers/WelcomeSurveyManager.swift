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
    
    @Published var handle: String = ""
    @Published var userColor: String = ""
    
    @Published var errorString: String = ""
    
    @Published var isLoadingWheelVisisble: Bool = false
    
    @Published var hasUserCompletedSurvey = true
    
    // Firestore
    let db = Firestore.firestore()
    
    var colorOptions = ["Black", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"]
    
    init() {
        self.userColor = colorOptions[0]
    }
    
    func completeWelcomeSurvey() {
        self.errorString = ""
        // Blank error cases
        if self.handle == "" {
            self.errorString = "Please enter a handle"
            return
        }
        
        // Whitespace error cases
        if self.handle.contains(where: { $0.isWhitespace }) {
            self.errorString = "Handle must not contain a whitespace"
            return
        }
        
        // Character count error cases
        if self.handle.count > 30 {
            self.errorString = "Handle is too long"
            return
        }
        
        db.collection("users").whereField("handle", isEqualTo: self.handle)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: ", err.localizedDescription)
                } else {
                    for _ in querySnapshot!.documents {
                        self.errorString = "Handle is already in use"
                        return
                    }
                    
                    // Otherwise handle is not already in use, continue with the setup.
                    self.isLoadingWheelVisisble = true
                    // Get user Id from firebase Auth
                    let userId = Auth.auth().currentUser!.uid
                    
                    // All fields are valid, update database and set UserDefault
                    self.db.collection("users").document(userId).updateData([
                        "handle": self.handle,
                        "userColor": self.userColor,
                        "hasUserCompletedWelcomeSurvey": true,
                        "isUserDeleted": false,
                        "isAdmin": false
                    ]) { err in
                        if let err = err {
                            print("Error updating user fields from welcome sruvey: \(err)")
                        } else {
//                            print("User updated successfully during welcome survey!")
                        }
                    }
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
