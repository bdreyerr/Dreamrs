//
//  UserManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class UserManager : ObservableObject {
    // ToDo
    // Firebase Storage
    
    
    // Rate Limiting
    @Published var numActionsInLastMinute: Int = 0
    @Published var firstActionDate: Date?
    
    // Firestore
    let db = Firestore.firestore()
    @Published var user: User?
    
    // Storage
    let storage = Storage.storage()
    
    // Parts of the user to display but not change in firestore.
    @Published var pinnedDreams: [Dream] = []
    @Published var pinnedDreamImages: [String : UIImage] = [:]
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
    
    func pinDream(dreamId: String, date: String) {
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
                
                // Write the pinned dream to firestore
                self.db.collection("users").document(user.id!).updateData([
                    "pinnedDreams": FieldValue.arrayUnion([pinnedDream])
                ]) { err in
                    if let err = err {
                        print("Error updating pinned dreams: \(err)")
                    } else {
                        print("Pinned Dreams successfully updated")
                        // update array locallay (need to do this because we dont refresh userManager.user) when loading the pinned dreams
                        self.user?.pinnedDreams!.append(pinnedDream)
                        self.loadPinnedDreams(isRefresh: true)
                    }
                }
                
            }
        }
    }
    
    func removePinnedDream(indexOfRemovedDream: Int) {
        if let user = self.user {
            if user.id == Auth.auth().currentUser?.uid {
                // Remove the already pinned dream at given index from firestore, then reload the pinned dreams array via the loadPinnedDreams function
                self.db.collection("users").document(user.id!).updateData([
                    "pinnedDreams": FieldValue.arrayRemove([self.user?.pinnedDreams![indexOfRemovedDream]])
                ]) { err in
                    if let err = err {
                        print("Error removing pinned Dream")
                    } else {
                        print("Pinned dream successfully removed")
                        self.user?.pinnedDreams!.remove(at: indexOfRemovedDream)
                        self.loadPinnedDreams(isRefresh: true)
                    }
                }
            }
        }
    }
    
    func loadPinnedDreams(isRefresh: Bool) {
        if let user = self.user {
            if let pinnedDreams = user.pinnedDreams {
                
                
                // If the call isn't for a refresh, and the array is already populated, do nothing
                // In this case refresh means a new dream has been pinned, and we want to reload the array from firebase.
                if !isRefresh {
                    if !self.pinnedDreams.isEmpty {
                        return
                    }
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
                            
                            // append image to local map if necessary
                            if let hasImage = dreamObject.hasImage {
                                if hasImage {
                                    // Download the image from firestore
                                    let imageRef = self.storage.reference().child(dream["dreamCollection"]! + "/" + dreamObject.id! + ".jpg")
                                    
                                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                                    imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                        if let error = error {
                                            print("Error downloading image from storage: ", error.localizedDescription)
                                        } else {
                                            // Data for "images/island.jpg" is returned
                                            let image = UIImage(data: data!)
                                            self.pinnedDreamImages[dreamObject.id!] = image
                                        }
                                    }
                                }
                            }
                            
                        case .failure(let error):
                            // A user value could not be initialized from the DocumentSnapshot
                            print("Failure retrieving dream from firestore: ", error.localizedDescription)
                        }
                    }
                    
                    
                    
                }
            }
        }
    }
    
    func updateUserFirstName(newFirstName: String) -> String? {
        var errorText: String?
        
        if let user = self.user {
            if newFirstName.count > 50 {
                return "Name too long"
            }
            
            let docRef = db.collection("users").document(user.id!)
            
            self.user?.firstName = newFirstName
            do {
                try docRef.setData(from: self.user)
            } catch {
                errorText = error.localizedDescription
            }
        }
        
        return errorText
    }
    
    func updateUserLastName(newLastName: String) -> String? {
        var errorText: String?
        
        if let user = self.user {
            if newLastName.count > 50 {
                return "Name too long"
            }
            
            let docRef = db.collection("users").document(user.id!)
            
            self.user?.lastName = newLastName
            do {
                try docRef.setData(from: self.user)
            } catch {
                errorText = error.localizedDescription
            }
        }
        
        return errorText
    }
    
    func updateUserHandle(newHandle: String) -> String? {
        var errorText: String?
        
        if let user = self.user {
            if newHandle.count > 50 {
                return "Name too long"
            }
            
            if newHandle.contains(where: { $0.isWhitespace }) {
                return "Handle must not contain a whitespace"
            }
            
            
            // check if handle already exists
            db.collection("users").whereField("handle", isEqualTo: newHandle)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: ", err.localizedDescription)
                    } else {
                        for _ in querySnapshot!.documents {
                            errorText = "Handle is already in use"
                            return
                        }
                        
                        // Otherwise handle is not already in use, continue with the setup.
                        let docRef = self.db.collection("users").document(user.id!)
                        
                        self.user?.handle = newHandle
                        do {
                            try docRef.setData(from: self.user)
                        } catch {
                            errorText = error.localizedDescription
                        }
                    }
                }
        }
        return errorText
    }
    
    // Rate limiting - limits firestore writes and blocks spamming in a singular user session. app is still prone to attacks in multiple app sessions (closing and re-opening)
    // Limits users to 5 writes in one minute
    func processFirestoreWrite() -> String? {
        var errorText: String?
        
        // Cases:
            // 1. This is the first action - first action date doesn't exist
                // Set first action to Date()
                // set num actions = 1
            // 2. First action exists - currentAction is less than one minute from first action
                // Allow action if numActions < 5
                    // set num actions += 1
                // Block action if numActions >= 5
            // 3. First action exists - current action is greater than one minute from first action
                // allow action
                // set first action date to Date()
                // set num action = 1
        
        if let firstActionDate = self.firstActionDate {
            
            // Get firstActionDate + 60 seconds
            let oneMinFromFirst = Calendar.current.date(byAdding: .second, value: 60, to: firstActionDate)
            
            if Date() < oneMinFromFirst! {
                if self.numActionsInLastMinute < 5 {
                    self.numActionsInLastMinute += 1
                } else {
                    return "Too many actions in one minute"
                }
            } else {
                self.firstActionDate = Date()
                self.numActionsInLastMinute = 1
            }
        } else {
            self.firstActionDate = Date()
            self.numActionsInLastMinute = 1
        }
        
        return errorText
    }
    
    func convertColorStringToView() -> Color {
        switch self.user?.userColor {
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
