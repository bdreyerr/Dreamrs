//
//  CreateDreamManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/6/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import RichTextKit

class CreateDreamManager : ObservableObject {
    // Dream Content
    @Published var title: String = ""
    @Published var text = NSAttributedString(string: "")
    @Published var context = RichTextContext()
    
    @Published var isReadyToSubmitPopupShowing: Bool = false
    
    // AI
    @Published var shouldVisualizeDream: Bool = true
    @Published var shouldAnalyzeDream: Bool = true
    // Community
    @Published var shareWithFriends: Bool = false
    @Published var shareWithCommunity: Bool = false
    
    @Published var retrievedText: NSAttributedString?
    
    var date: String?
    let dateFormatter = DateFormatter()
    
    // Firestore
    let db = Firestore.firestore()
    
    init() {
        context.fontName = "Hoefler Text"
        context.fontSize = 15
//        context.isEditingText = true
        
        dateFormatter.dateFormat = "MMMM dd'th', yyyy"
        date = dateFormatter.string(from: Date.now)
    }
    
//    deinit {
//        print("leaving")
//        context.isEditingText = false
//    }
    
    
    // TODO: Decide how we grab the userId, either from view or check Auth or whatever
    func submitDream(userId: String, userHandle: String) -> Dream? {
        // Check the userId passed from view matches the Auth.auth().currentuser
        if Auth.auth().currentUser?.uid != userId {
            print("user ids do not match")
            return nil
        }
        
        if self.title == "" || self.text == NSAttributedString(string: "") {
            print("content is empty")
        }
        
        // plain text and formatting data
        let string = self.text.string
        let archivedData: Data = try! NSKeyedArchiver.archivedData(withRootObject: self.text, requiringSecureCoding: false)
        
        
        let date = Date()
        let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
        // Get today's day of week
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: Date())
        let dayOfWeekString = calendar.weekdaySymbols[dayOfWeek - 1]
        
        // Create a dream object
        let dream = Dream(authorId: userId, authorHandle: userHandle, title: self.title, plainText: string, archivedData: archivedData, date: formattedDate, dayOfWeek: dayOfWeekString, karma: 1, sharedWithFriends: self.shareWithFriends, sharedWithCommunity: self.shareWithCommunity)
        
        
        // Get the month and year
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMYYYY" // Format for full month name and year
        let currentMonthYearString = dateFormatter.string(from: Date())

        print(currentMonthYearString) // Example output: "December 2023"
        
        // Save the dream to firestore
        let dreamsRef = db.collection("dreams" + currentMonthYearString)
        do {
            let newDreamRef = try dreamsRef.addDocument(from: dream)
            print("Dream stored with new doc reference: ", newDreamRef.documentID)
            return dream
        } catch {
            print("Error saving dream to firestore: ", error.localizedDescription)
            return nil
        }
    }
    
    func retrieveDream() {
        let docRef = db.collection("dreams").document("hfMdmDmZpnrmtn9wIObg")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                // Set the archived Data
                let archivedData = document.data()!["archivedData"] as! Data
                self.retrievedText = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? NSAttributedString
            } else {
                print("Document does not exist")
            }
        }
    }
    
}
