//
//  HomeManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/11/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class HomeManager : ObservableObject {
    
    @Published var selectedMonth: String
    var months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "Novemeber", "December"]
    
    
    @Published var retrievedDreams : [Dream] = []
    
    @Published var isCreateDreamPopupShowing: Bool = false
    
    @Published var focusedDream: Dream?
    @Published var focusedTextFormatted: NSAttributedString?
    
    // Post Publish Vars (Viewing newly created dreams)
    @Published var isViewNewlyCreatedDreamPopupShowing: Bool = false
    @Published var isNewDreamLoading: Bool = true
    @Published var isErrorLoadingNewDream: Bool = false
    
    // Firestore
    let db = Firestore.firestore()
    
    init() {
        // Find the current month, set the selector
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        selectedMonth = months[currentMonth - 1]
    }
    
    func retrieveDreams(userId: String) {
        // validate user id
        if userId != Auth.auth().currentUser?.uid { return }
        
        self.retrievedDreams = []
        
        // read from only the selected month of the current year
        // TODO(bendreyer): add multi year functionality later
        let dreamSubcollection = selectedMonth+"2024"
        
        // start with getting all documents from a current user (build dream individualy)
        db.collection("dreams" + dreamSubcollection).whereField("authorId", isEqualTo: userId).order(by: "date")
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
                        let dayOfWeek = document.data()["dayOfWeek"] as? String
                        let karma = document.data()["karma"] as? Int
                        let sharedWithFriends = document.data()["sharedWithFriends"] as? Bool
                        let sharedWithCommunity = document.data()["sharedWithCommunity"] as? Bool
                        
                        let dream = Dream(id: id, authorId: userId, title: title, plainText: plainText, archivedData: archivedData, date: date, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity)
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
}
