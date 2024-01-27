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
    
    // Following traffic
    @Published var retrievedDreamsToday: [Dream] = []
    @Published var retrievedDreamsThisMonth: [Dream] = []
    // For you traffic
    @Published var retrievedDreamsTodayForYou: [Dream] = []
    @Published var retrievedDreamsThisMonthForYou: [Dream] = []
    // Limit document queries
    @Published var lastDoc: QueryDocumentSnapshot?
    @Published var shouldLoadMoreDreamsButtonBeVisible: Bool = false
    
    @Published var focusedDream: Dream?
    @Published var focusedTextFormatted: NSAttributedString?
    
    @Published var localKarmaVotes : [String: Bool] = [:]
    
    @Published var focusedProfile: User?
    @Published var focusedProfilesPinnedDreams: [Dream] = []
    
    @Published var isSearchBarShowing: Bool = false
    @Published var searchText: String = ""
    @Published var searchedProfiles: [User] = []
    
    // Firestore
    let db = Firestore.firestore()
    
    init() {
        selectedTimeFilter = timeFilters[1]
        selectedTrafficSlice = trafficSlices[0]
    }
    
    func retrieveDreams(userId: String, following: [String], isInfiniteScrollRequest: Bool) {
        if userId != Auth.auth().currentUser?.uid { return }
        
        
        // Cache the dreams already retrieved so that we do not make unnecessary calls to firestore.
        if !isInfiniteScrollRequest {
            if self.selectedTimeFilter == self.timeFilters[0] {
                if !self.retrievedDreamsToday.isEmpty && self.selectedTrafficSlice == self.trafficSlices[0] {
                    return
                }
                if !self.retrievedDreamsTodayForYou.isEmpty && self.selectedTrafficSlice == self.trafficSlices[1] {
                    return
                }
            } else {
                if !self.retrievedDreamsThisMonth.isEmpty && self.selectedTrafficSlice == self.trafficSlices[0] {
                    return
                }
                if !self.retrievedDreamsThisMonthForYou.isEmpty && self.selectedTrafficSlice == self.trafficSlices[1]{
                    return
                }
            }
        }
        
        var numPostsInCurBatch: Int = 0
        
        
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
            
            // set Dream ref based on if we are looking at following or for you page, as well as Today vs. This Month
            if self.selectedTrafficSlice == self.trafficSlices[0] {
                if isInfiniteScrollRequest {
                    // Today, Following, not first batch
                    dreamRef = db.collection(collectionString).whereField("authorId", in: following).whereField("date", isEqualTo: formattedDate).whereField("sharedWithFriends", isEqualTo: true).order(by: "rawTimestamp", descending: false).start(afterDocument: self.lastDoc!).limit(to: 20)
                } else {
                    // Today, following, first batch
                    dreamRef = db.collection(collectionString).whereField("authorId", in: following).whereField("date", isEqualTo: formattedDate).whereField("sharedWithFriends", isEqualTo: true).order(by: "rawTimestamp", descending: false).limit(to: 20)
                }
                
            } else {
                if isInfiniteScrollRequest {
                    // Today, For You, Not first batch
                    dreamRef = db.collection(collectionString).whereField("date", isEqualTo: formattedDate).whereField("sharedWithCommunity", isEqualTo: true).order(by: "rawTimestamp", descending: false).start(afterDocument: self.lastDoc!).limit(to: 20)
                } else {
                    // Today, For You, First Batch
                    dreamRef = db.collection(collectionString).whereField("date", isEqualTo: formattedDate).whereField("sharedWithCommunity", isEqualTo: true).order(by: "rawTimestamp", descending: false).limit(to: 20)
                }
                
            }
            
        } else if self.selectedTimeFilter == self.timeFilters[1] {
            // Retrieve all dreams this month, depending on traffic slice (following vs. for you)
            if self.selectedTrafficSlice == self.trafficSlices[0] {
                if isInfiniteScrollRequest {
                    // This month, Following, Not first batch
                    dreamRef = db.collection(collectionString).whereField("authorId", in: following).whereField("sharedWithFriends", isEqualTo: true).order(by: "rawTimestamp", descending: false).start(afterDocument: self.lastDoc!).limit(to: 20)
                } else {
                    // This month, Following, First Batch
                    dreamRef = db.collection(collectionString).whereField("authorId", in: following).whereField("sharedWithFriends", isEqualTo: true).order(by: "rawTimestamp", descending: false).limit(to: 20)
                }
                
            } else {
                if isInfiniteScrollRequest {
                    // This month, For You, Not First Batch
                    dreamRef = db.collection(collectionString).whereField("sharedWithCommunity", isEqualTo: true).order(by: "rawTimestamp", descending: false).start(afterDocument: self.lastDoc!).limit(to: 20)
                } else {
                    // This Month, For You, first Batch
                    dreamRef = db.collection(collectionString).whereField("sharedWithCommunity", isEqualTo: true).order(by: "rawTimestamp", descending: false).limit(to: 20)
                }
                
            }
            
        }
        
        // Get all dreams from all users in the following array
        if isInfiniteScrollRequest {
            dreamRef.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("error retrieving next set of posts: \(error?.localizedDescription ?? "x")")
                    return
                }
                
                for document in snapshot.documents {
                    let id = document.documentID
                    let authorId = document.data()["authorId"] as? String
                    let authorHandle = document.data()["authorHandle"] as? String
                    let authorColor = document.data()["authorColor"] as? String
                    let title = document.data()["title"] as? String
                    let plainText = document.data()["plainText"] as? String
                    let archivedData = document.data()["archivedData"] as? Data
                    let date = document.data()["date"] as? String
                    let rawTimestamp = document.data()["rawTimestamp"] as? Timestamp
                    let dayOfWeek = document.data()["dayOfWeek"] as? String
                    let karma = document.data()["karma"] as? Int
                    let sharedWithFriends = document.data()["sharedWithFriends"] as? Bool
                    let sharedWithCommunity = document.data()["sharedWithCommunity"] as? Bool
                    let tags = document.data()["tags"] as? [[String : String]]
                    
                    let dream = Dream(id: id, authorId: authorId, authorHandle: authorHandle, authorColor: authorColor, title: title, plainText: plainText, archivedData: archivedData, date: date, rawTimestamp: rawTimestamp, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity, tags: tags)
                    print("appended a dream with timestamp: ", rawTimestamp ?? "None")
                    
                    
                    if self.selectedTrafficSlice == self.trafficSlices[0] {
                        // Following
                        if dream.sharedWithFriends ?? false {
                            if self.selectedTimeFilter == self.timeFilters[0] {
                                // Today's dreams
                                self.retrievedDreamsToday.append(dream)
                            } else if self.selectedTimeFilter == self.timeFilters[1] {
                                // This month's dreams
                                self.retrievedDreamsThisMonth.append(dream)
                            }
                        }
                    } else if self.selectedTrafficSlice == self.trafficSlices[1] {
                        // For you
                        if dream.sharedWithCommunity ?? false {
                            if self.selectedTimeFilter == self.timeFilters[0] {
                                // Today's Dreams
                                self.retrievedDreamsTodayForYou.append(dream)
                            } else if self.selectedTimeFilter == self.timeFilters[1] {
                                // This month's dreams
                                self.retrievedDreamsThisMonthForYou.append(dream)
                            }
                        }
                    }
                    numPostsInCurBatch += 1
                }
                
                if numPostsInCurBatch >= 20 {
                    self.shouldLoadMoreDreamsButtonBeVisible = true
                } else {
                    self.shouldLoadMoreDreamsButtonBeVisible = false
                }
                
                guard let lastDocument = snapshot.documents.last else {
                    // The collection is empty
                    return
                }
                
                self.lastDoc = lastDocument
            }
        } else if !isInfiniteScrollRequest {
            dreamRef.getDocuments() { (querySnapshot, error) in
                if let err = error {
                    print("error getting dreams: ", err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        let id = document.documentID
                        let authorId = document.data()["authorId"] as? String
                        let authorHandle = document.data()["authorHandle"] as? String
                        let authorColor = document.data()["authorColor"] as? String
                        let title = document.data()["title"] as? String
                        let plainText = document.data()["plainText"] as? String
                        let archivedData = document.data()["archivedData"] as? Data
                        let date = document.data()["date"] as? String
                        let rawTimestamp = document.data()["rawTimestamp"] as? Timestamp
                        let dayOfWeek = document.data()["dayOfWeek"] as? String
                        let karma = document.data()["karma"] as? Int
                        let sharedWithFriends = document.data()["sharedWithFriends"] as? Bool
                        let sharedWithCommunity = document.data()["sharedWithCommunity"] as? Bool
                        let tags = document.data()["tags"] as? [[String : String]]
                        
                        let dream = Dream(id: id, authorId: authorId, authorHandle: authorHandle, authorColor: authorColor, title: title, plainText: plainText, archivedData: archivedData, date: date, rawTimestamp: rawTimestamp, dayOfWeek: dayOfWeek, karma: karma, sharedWithFriends: sharedWithFriends, sharedWithCommunity: sharedWithCommunity, tags: tags)
                        print("appended a dream with timestamp: ", rawTimestamp ?? "None")
                        
                        
                        if self.selectedTrafficSlice == self.trafficSlices[0] {
                            // Following
                            if dream.sharedWithFriends ?? false {
                                if self.selectedTimeFilter == self.timeFilters[0] {
                                    // Today's dreams
                                    self.retrievedDreamsToday.append(dream)
                                } else if self.selectedTimeFilter == self.timeFilters[1] {
                                    // This month's dreams
                                    self.retrievedDreamsThisMonth.append(dream)
                                }
                            }
                        } else if self.selectedTrafficSlice == self.trafficSlices[1] {
                            // For you
                            if dream.sharedWithCommunity ?? false {
                                if self.selectedTimeFilter == self.timeFilters[0] {
                                    // Today's Dreams
                                    self.retrievedDreamsTodayForYou.append(dream)
                                } else if self.selectedTimeFilter == self.timeFilters[1] {
                                    // This month's dreams
                                    self.retrievedDreamsThisMonthForYou.append(dream)
                                }
                            }
                        }
                        numPostsInCurBatch += 1
                    }
                    
                    self.lastDoc = querySnapshot!.documents.last
                    if numPostsInCurBatch >= 20 {
                        self.shouldLoadMoreDreamsButtonBeVisible = true
                    } else {
                        self.shouldLoadMoreDreamsButtonBeVisible = false
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
        
        // Update the posts Karma based on what the user has already voted already (update a local map and firestore simultaneously so the user can observe the local change while the db updates - we don't re-read the document in firestore).
        // Options:
        //   If the user hasn't voted on the dream already
        //      1. Update the karma based on upvote or downvote
        //   If the user has upvoted already
        //      1. If upvoting again, karma -= 1
        //      2. If downvoting, karma -= 2
        //   If the user has downvoted already
        //      1. If upvoting, karma += 2
        //      2. If downvoting, karma += 1
        
        var netKarma = 0
        
        if !self.localKarmaVotes.keys.contains(dream.id!) {
            netKarma = isUpvote ? 1 : -1
            self.localKarmaVotes[dream.id!] = isUpvote ? true : false
        } else if self.localKarmaVotes[dream.id!] == true {
            netKarma  = isUpvote ? -1 : -2
            if isUpvote {
                self.localKarmaVotes.removeValue(forKey: dream.id!)
            } else {
                self.localKarmaVotes[dream.id!] = false
            }
        } else if self.localKarmaVotes[dream.id!] == false {
            netKarma = isUpvote ? 2 : 1
            if isUpvote {
                self.localKarmaVotes[dream.id!] = true
            } else {
                self.localKarmaVotes.removeValue(forKey: dream.id!)
            }
        }
        
        db.collection(collectionString).document(dream.id!).updateData([
            "karma": FieldValue.increment(Int64(netKarma))
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
//    func getColorForHandle() -> Color {
//        let randomColor = Int.random(in: 0...6)
//        switch randomColor {
//        case 0:
//            return .green
//        case 1:
//            return .orange
//        case 2:
//            return .red
//        case 3:
//            return .blue
//        case 4:
//            return .purple
//        case 5:
//            return .brown
//        case 6:
//            return .cyan
//        default:
//            return .gray
//        }
//    }
    
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
                self.loadPinnedDreams()
            case .failure(let error):
                // A user value could not be initialized from the DocumentSnapshot
                print("Failure retrieving user from firestore: ", error.localizedDescription)
            }
        }
    }
    
    func loadPinnedDreams() {
        // We'll re-call this function every time the communityProfileView appears because there's no way to tell if it's a different user or not
        print("In load pinned dreams")
        
        self.focusedProfilesPinnedDreams = []
        
        if let user = self.focusedProfile {
            if let pinnedDreams = user.pinnedDreams {
                for dream in pinnedDreams {
                    // Grab Document
                    let docRef = db.collection(dream["dreamCollection"]!).document(dream["dreamId"]!)
                    docRef.getDocument(as: Dream.self) { result in
                        switch result {
                        case .success(let dreamObject):
                            // A user value was successfully initialized from the Documentsnapshot
                            self.focusedProfilesPinnedDreams.append(dreamObject)
                        case .failure(let error):
                            // A user value could not be initialized from the DocumentSnapshot
                            print("Failure retrieving dream from firestore: ", error.localizedDescription)
                        }
                    }
                }
            } else {
                print("no pinned dreams")
            }
            
        } else {
            print("no user")
        }
        
    }
    
    func searchCommunityProfiles() {
        // Search the user collection in firestore for the exact userHandle
        
        // Options to implement this function:
            // 1. search once when a user presses the search button
            // 2. search at every new character added to the handle query (real time update)
        
        // Lets go with option one for now
        // we can create a list of Published Users which match this search query, and when a user clicks on one, we can use the focusedProfile to display that users profile
        let userHandle = self.searchText
        self.searchedProfiles = []
        
        let docRef = db.collection("users").whereField("handle", isEqualTo: userHandle).order(by: "karma", descending: true)
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error searching community profiles: ", err.localizedDescription)
            } else if let qSnapshot = querySnapshot {
                for document in qSnapshot.documents {
                    let user = User(
                        id: document.documentID,
                        firstName: document.data()["firstName"] as? String,
                        lastName: document.data()["lastName"] as? String,
                        email: document.data()["email"] as? String,
                        handle: document.data()["handle"] as? String,
                        userColor: document.data()["userColor"] as? String,
                        following: document.data()["following"] as? [String],
                        followers: document.data()["followers"] as? [String],
                        numDreams: document.data()["numDreams"] as? Int,
                        karma: document.data()["karma"] as? Int,
                        pinnedDreams: document.data()["pinnedDreams"] as? [[String: String]],
                        hasUserCompletedWelcomeSurvey: document.data()["hasUserCompletedWelcomeSurvey"] as? Bool
                    )
                    self.searchedProfiles.append(user)
                }
            }
        }
    }
    
    func randomImage() -> String {
        let randomNumber = Int.random(in: 2...6)
        return "dream\(randomNumber)"
    }
}
