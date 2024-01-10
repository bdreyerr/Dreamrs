//
//  UserManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager : ObservableObject {
    // ToDo
    // Rate Limiting
    // Firebase Storage
    
    // Firestore
    let db = Firestore.firestore()
    @Published var user: User?
    
    // Parts of the user to display but not change in firestore.
    @Published var pinnedDreams: [Dream] = []
    @Published var followers: [User] = []
    
    func retrieverUserFromFirestore(userId: String) {
        // Grab Document
        let docRef = db.collection("users").document(userId)
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let userObject):
                // A user value was successfully initialized from the Documentsnapshot
                self.user = userObject
                print("The user was successfully retrieved from firestore, access it with userManager.user")
            case .failure(let error):
                // A user value could not be initialized from the DocumentSnapshot
                print("Failure retrieving user from firestore: ", error.localizedDescription)
            }
        }
    }
    
    func followProfile(profileId: String) {
        if let user = self.user {
            db.collection("users").document(user.id!).updateData([
                "following": FieldValue.arrayUnion([profileId])
            ]) { err in
                if let err = err {
                    print("Error following user: ", err)
                } else {
                    print("User followed successfully")
                }
            }
        }
    }
    
    func unfollowProfile(profileId: String) {
        if let user = self.user {
            db.collection("users").document(user.id!).updateData([
                "following": FieldValue.arrayRemove([profileId])
            ]) { err in
                if let err = err {
                    print("Error unfollowing user: ", err)
                } else {
                    print("User unfollowed successfully")
                }
            }
        }
    }
    
    func loadFollowers() {
        if self.followers.isEmpty {
            if let user = self.user {
                let docRef = db.collection("users")
                for follower in user.followers! {
                    // Lookup user from firestore return User Object
                    docRef.document(follower).getDocument(as: User.self) { result in
                        switch result {
                        case .success(let userObject):
                            // A user value was successfully initialized from the Documentsnapshot
                            self.followers.append(userObject)
                            print("Follower retrieved")
                        case .failure(let error):
                            // A user value could not be initialized from the DocumentSnapshot
                            print("Error retrieving follower: ", error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func pinDream(dreamId: String, date: String, indexOfReplacedDream: Int) {
        if let user = self.user {
            // Verify signed in user is the user attatched to userManager
            if user.id == Auth.auth().currentUser?.uid {
                // Parse the dream collection from the date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                guard let date = dateFormatter.date(from: date) else {
                    // Handle the error if the string cannot be parsed
                    print("date could not be parsed")
                    return
                }
                
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMMMyyyy" // Capitalized month name and year
                let formattedString = outputFormatter.string(from: date)
                print("dreams" + formattedString) // Output: January2024
                
                // Create a map for the pinned dream
                let pinnedDream : [String : String] = [
                    "dreamCollection" : "dreams" + formattedString,
                    "dreamId": dreamId
                ]
                
                // Write the pinned dream to firestore, replacing an old dream if need be
                if indexOfReplacedDream == -1 {
                    self.db.collection("users").document(user.id!).updateData([
                        "pinnedDreams": FieldValue.arrayUnion([pinnedDream])
                    ]) { err in
                        if let err = err {
                            print("Error updating pinned dreams: \(err)")
                        } else {
                            print("Pinned Dreams successfully updated")
                            // Update locally as well.
                            self.user?.pinnedDreams?.append(pinnedDream)
                            self.loadPinnedDreams(loadingNewDream: true)
                        }
                    }
                }
            }
        }
    }
    
    func loadPinnedDreams(loadingNewDream: Bool) {
        if let user = self.user {
            if let pinnedDreams = user.pinnedDreams {
                
                // If dreams are already loaded don't re-read
                if !self.pinnedDreams.isEmpty && !loadingNewDream {
                    return
                }
                
                self.pinnedDreams = []
                
                // Retrieve each dream from firebase
                for dream in pinnedDreams {
                    // Grab Document
                    let docRef = db.collection(dream["dreamCollection"]!).document(dream["dreamId"]!)
                    docRef.getDocument(as: Dream.self) { result in
                        switch result {
                        case .success(let dreamObject):
                            // A user value was successfully initialized from the Documentsnapshot
                            self.pinnedDreams.append(dreamObject)
                            print("Added dream to pinned dreams")
                        case .failure(let error):
                            // A user value could not be initialized from the DocumentSnapshot
                            print("Failure retrieving dream from firestore: ", error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
