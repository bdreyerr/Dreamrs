//
//  CommunityManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/4/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class CommunityManager : ObservableObject {
    
    @Published var selectedTrafficSlice: String
    var trafficSlices = ["Following", "For You"]
    
    @Published var selectedTimeFilter: String
    var timeFilters = ["Today", "This Month"]
    
    @Published var retrievedDreamsToday: [Dream] = []
    @Published var retrievedDreamsThisMonth: [Dream] = []
    
    @Published var focusedDream: Dream?
    @Published var focusedTextFormatted: NSAttributedString?
    
    @Published var focusedProfile: User?
    
    // Firestore
    let db = Firestore.firestore()
    
    init() {
        selectedTimeFilter = timeFilters[0]
        selectedTrafficSlice = trafficSlices[0]
    }
    
    func retrieveDreams(userId: String, following: [String]) {
        if userId != Auth.auth().currentUser?.uid { return }
        
        // Cache the dreams already retrieved so that we do not make unnecessary calls to firestore.
        if self.selectedTimeFilter == self.timeFilters[0] {
            if !self.retrievedDreamsToday.isEmpty {
                return
            }
        } else {
            if !self.retrievedDreamsThisMonth.isEmpty {
                return
            }
        }
        
        
        // TODO: implement infnite scroll
        // for now we just use the current month and get all
        
        // Get currentMonth + year string
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.month, .year], from: Date())
        let month = DateFormatter().monthSymbols[dateComponents.month! - 1]
        let year = String(dateComponents.year!)
        let currentDateString = "\(month)\(year)"
        let collectionString = "dreams\(currentDateString)"
        print(collectionString)
        
        
        var dreamRef = db.collection("dreams").whereField("authorId", isEqualTo: userId)
        
        if self.selectedTimeFilter == self.timeFilters[0] {
            // Only retrieve todays Dreams
            
            // Get todays date in format: MMM D, YYYY
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy" // Set the desired format

            let today = Date()               // Get the current date
            let formattedDate = dateFormatter.string(from: today) // Format the date

            print(formattedDate) // Output: Jan 5, 2024 (assuming today's date)
            dreamRef = db.collection(collectionString).whereField("authorId", in: following).whereField("date", isEqualTo: formattedDate)
        } else if self.selectedTimeFilter == self.timeFilters[1] {
            // Retrieve all dreams this month
            dreamRef = db.collection(collectionString).whereField("authorId", in: following)
        }
        
        // Get all dreams from all users in the following array
        dreamRef.getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("error getting dreams: ", err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let authorId = document.data()["authorId"] as? String
                    let authorHandle = document.data()["authorHandle"] as? String
                    let title = document.data()["title"] as? String
                    let plainText = document.data()["plainText"] as? String
                    let archivedData = document.data()["archivedData"] as? Data
                    let date = document.data()["date"] as? String
                    let dayOfWeek = document.data()["dayOfWeek"] as? String
                    let karma = document.data()["karma"] as? Int
                    let sharedWithFriends = document.data()["sharedWithFriends"] as? Bool
                    let sharedWithCommunity = document.data()["sharedWithCommunity"] as? Bool
                    let tags = document.data()["tags"] as? [[String : String]]
                    
                    let dream = Dream(id: id, authorId: authorId, authorHandle: authorHandle, title: title, plainText: plainText, archivedData: archivedData, date: date, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity, tags: tags)
                    
                    if dream.sharedWithFriends ?? false {
                        if self.selectedTimeFilter == self.timeFilters[0] {
                            self.retrievedDreamsToday.append(dream)
                        } else if self.selectedTimeFilter == self.timeFilters[1] {
                            self.retrievedDreamsThisMonth.append(dream)
                        }
                    }
                }
            }
        }
    }
    
    func displayDream(dream: Dream) {
        self.focusedDream = dream
        self.focusedTextFormatted = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dream.archivedData!) as? NSAttributedString
//        self.focusedTextFormatted = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: dream.archivedData!)
    }
    
    // Karma Voting
    func processKarmaVote(userId: String, dream: Dream, isUpvote: Bool) {
        // Get current month and year for collection string.
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.month, .year], from: Date())
        let month = DateFormatter().monthSymbols[dateComponents.month! - 1]
        let year = String(dateComponents.year!)
        let currentDateString = "\(month)\(year)"
        let collectionString = "dreams\(currentDateString)"
        print(collectionString)
        
        // Update the posts Karma
        db.collection(collectionString).document(dream.id!).updateData([
            "karma": FieldValue.increment(Int64(isUpvote ? 1 : -1))
        ]) { err in
            if let err = err {
                print("Error updating dream karma: \(err)")
            } else {
                print("Dream Karma successfully updated")
            }
        }
        
        print(dream.authorId!)
        print(dream.authorHandle!)
        // Update the authors Karma
        db.collection("users").document(dream.authorId!).updateData([
            "karma": FieldValue.increment(Int64(isUpvote ? 1 : -1))
        ]) { err in
            if let err = err {
                print("Error updating user's karma: ", err.localizedDescription)
            } else {
                print("Successfully updated user's karma")
            }
        }
        
        // Add the dream to the signed in user's upvoted list. (if it's an upvote)
    }
    
    
    // TODO: Give each user a color, which will be displayed on their profile page and in community forum so we don't need to generate a random color which changes everytime the view reloads.
    func getColorForHandle() -> Color {
        let randomColor = Int.random(in: 0...6)
        switch randomColor {
        case 0:
            return .green
        case 1:
            return .orange
        case 2:
            return .red
        case 3:
            return .blue
        case 4:
            return .purple
        case 5:
            return .brown
        case 6:
            return .cyan
        default:
            return .gray
        }
    }
    
    func convertStringToColor(color: String) -> Color {
        switch color {
        case "red":
            return Color.red
        case "blue":
            return Color.blue
        case "green":
            return Color.green
        case "purple":
            return Color.purple
        case "cyan":
            return Color.cyan
        case "yellow":
            return Color.yellow
        case "orange":
            return Color.orange
        default:
            return Color.red
            
        }
    }
    
    func retrieverUserFromFirestore(userId: String) {
        // Grab Document
        let docRef = db.collection("users").document(userId)
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let userObject):
                // A user value was successfully initialized from the Documentsnapshot
                self.focusedProfile = userObject
                print("The community user was successfully retrieved from firestore, access them with communityManager.focusedProfile")
            case .failure(let error):
                // A user value could not be initialized from the DocumentSnapshot
                print("Failure retrieving user from firestore: ", error.localizedDescription)
            }
        }
    }
    
    func randomImage() -> String {
        let randomNumber = Int.random(in: 2...6)
        return "dream\(randomNumber)"
    }
}
