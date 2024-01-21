//
//  HomeManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/11/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI


class HomeManager : ObservableObject {
    
    @Published var selectedMonth: String
    var months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "Novemeber", "December"]
    @Published var selectedYear: String
    var years = ["2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"]
    
    
    @Published var retrievedDreams : [Dream] = []
    
    @Published var isCreateDreamPopupShowing: Bool = false
    
    @Published var focusedDream: Dream?
    @Published var focusedTextFormatted: NSAttributedString?
    @Published var isFocusedDreamPinned: Bool = false
    
    // Post Publish Vars (Viewing newly created dreams)
    @Published var isViewNewlyCreatedDreamPopupShowing: Bool = false
    @Published var isNewDreamLoading: Bool = true
    @Published var isErrorLoadingNewDream: Bool = false
    
    @Published var isConfirmPinnedDreamPopupShowing: Bool = false
    
    // Firestore
    let db = Firestore.firestore()
    
    init() {
        // Find the current month, set the selector
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        selectedMonth = months[currentMonth - 1]
        // Hardcoded to 2024, eventually set to current year based on calendar
        selectedYear = years[5]
    }
    
    func retrieveDreams(userId: String) {
        // validate user id
        if userId != Auth.auth().currentUser?.uid { return }
        
        self.retrievedDreams = []
        
        // read from only the selected month of the current year
        // TODO(bendreyer): add multi year functionality later
        let dreamSubcollection = selectedMonth+selectedYear
        
        // start with getting all documents from a current user (build dream individualy)
        db.collection("dreams" + dreamSubcollection).whereField("authorId", isEqualTo: userId).order(by: "rawTimestamp", descending: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: ", err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        let id = document.documentID
                        let title = document.data()["title"] as? String
                        let plainText = document.data()["plainText"] as? String
                        let archivedData = document.data()["archivedData"] as? Data
                        let date = document.data()["date"] as? String
                        let rawTimestamp = document.data()["rawTimestamp"] as? Date
                        let dayOfWeek = document.data()["dayOfWeek"] as? String
                        let karma = document.data()["karma"] as? Int
                        let sharedWithFriends = document.data()["sharedWithFriends"] as? Bool
                        let sharedWithCommunity = document.data()["sharedWithCommunity"] as? Bool
                        let tags = document.data()["tags"] as? [[String : String]]
                        
                        let dream = Dream(id: id, authorId: userId, title: title, plainText: plainText, archivedData: archivedData, date: date, rawTimestamp: rawTimestamp, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity, tags: tags)
                        self.retrievedDreams.append(dream)
                    }
                }
                
            }
    }
    
    // Called after a dream is created in CreateDreamManager, processes the AI aspects of the dream
    func processNewDream(dream: Dream, shouldVisualizeDream: Bool, shouldAnalyzeDream: Bool) {
        if shouldVisualizeDream {
            // generate an Image based on the dream plain text
            
            // store the image in firebase storage
            
            // attatch the storage reference id onto the dream document in firestore db
            
            // DL the image and attatch it to the focused dream
            
            // 
            
            if shouldAnalyzeDream {
                // Generate analysis text based on dream plain text
                
                // Store the analysis on the firestore object add it to the focused dream
                
                self.isNewDreamLoading = false
            }
        } else if shouldAnalyzeDream {
            // Same as above
            
            self.isNewDreamLoading = false
        }
        
        self.isNewDreamLoading = false
    }
    
    func displayDream(dream: Dream) {
        self.focusedDream = dream
        self.focusedTextFormatted = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dream.archivedData!) as? NSAttributedString
//        self.focusedTextFormatted = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: dream.archivedData!)
    }
    
    func randomImage() -> String {
        let randomNumber = Int.random(in: 2...6)
        return "dream\(randomNumber)"
    }
    
    func convertStringToColor(color: String) -> Color {
        switch color {
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
            return Color.blue
            
        }
    }
}
