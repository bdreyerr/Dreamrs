//
//  CreateDreamManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/6/23.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import RichTextKit
import SwiftUI

class CreateDreamManager : ObservableObject {
    // Dream Content
    @Published var title: String = ""
    @Published var text = NSAttributedString(string: "")
    @Published var context = RichTextContext()
    
    // Tags
    @Published var tagText: String = ""
    @Published var tags : [Tag] = [Tag(id: UUID().uuidString, index: 0, text: "Dream", icon: "sun.max", color: "red")]
    var colorOptions = ["Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"]
    var iconOptions = ["message.fill", "phone.down.fill", "sun.max", "cloud.bolt.rain", "figure.walk.circle", "car", "paperplane.fill", "studentdesk", "display.2", "candybarphone", "photo.fill", "arrow.triangle.2.circlepath", "flag.checkered", "gamecontroller", "network.badge.shield.half.filled", "dot.radiowaves.left.and.right", "airplane.circle.fill", "bicycle", "snowflake.circle", "key.fill", "person.fill", "person.3", "house.fill", "party.popper.fill", "figure.archery", "sportscourt.fill", "globe.americas.fill", "sun.snow", "moon.fill", "wind.snow", "bolt.square.fill", "wand.and.stars.inverse", "bandage.fill", "textformat.abc", "play.rectangle.fill", "shuffle", "command.circle.fill", "keyboard.fill", "cart.fill", "giftcard.fill", "pesosign.circle", "chineseyuanrenminbisign.circle.fill", "hourglass.circle.fill", "heart.fill", "pill.fill", "eye", "brain.fill", "percent"]
    
    
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
        context.isEditingText = true
        
        dateFormatter.dateFormat = "MMMM dd'th', yyyy"
        date = dateFormatter.string(from: Date.now)
    }
    
//    deinit {
//        print("leaving")
//        context.isEditingText = false
//    }
    
    func addTagtoDream(text: String) {
        // Cap at 5 Tags
        if self.tags.count < 5 {
            if self.tagText.count < 35 {
                let newTag = Tag(id: UUID().uuidString, index: self.tags.count, text: text, icon: self.iconOptions.randomElement()!, color: self.colorOptions.randomElement()!)
                self.tags.append(newTag)
                print("added new tag, index: ", newTag.index)
            }
        }
    }
    
    func removeTagFromDream(index: Int) {
        print(self.tags)
        print("tag index to be deleted: ", index)
        self.tags.remove(at: index)
        
        if !self.tags.isEmpty {
            for i in 0...self.tags.count - 1 {
                self.tags[i].index = i
            }
        }
        
    }
    
    
    // TODO: Decide how we grab the userId, either from view or check Auth or whatever
    func submitDream(userId: String, userHandle: String, userColor: String) -> Dream? {
        // Check the userId passed from view matches the Auth.auth().currentuser
        if Auth.auth().currentUser?.uid != userId {
            print("user ids do not match")
            return nil
        }
        
        if self.title == "" || self.text == NSAttributedString(string: "") {
            print("content is empty")
        }
        
        if self.text.string.count >= 2000 {
            print("dream length is too long.")
            return nil
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
        let rawDate = Date.now
        let rawTimestamp = Timestamp(date: date)
        
        
        // Create Tags Array
        var tagArray: [[String : String]] = []
        for i in 0...self.tags.count - 1{
            let tagDict: [String:String] = ["text":self.tags[i].text, "icon":self.tags[i].icon, "color":self.tags[i].color]
            tagArray.append(tagDict)
        }
        print("Tag array looks like: ")
        print(tagArray)
        
        // Create a dream object
        var dream = Dream(authorId: userId, authorHandle: userHandle, authorColor: userColor, title: self.title, plainText: string, archivedData: archivedData, date: formattedDate, rawTimestamp: rawTimestamp, dayOfWeek: dayOfWeekString, karma: 1, sharedWithFriends: self.shareWithFriends, sharedWithCommunity: self.shareWithCommunity, tags: tagArray)
        
        
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
            
            // update the local dream id
            dream.id = newDreamRef.documentID
            
            // Add 1 to users num derams
            // TODO add error handling
            let userRef = db.collection("users").document(userId)
            userRef.updateData([
                "numDreams": FieldValue.increment(Int64(1))
            ])
            
            return dream
        } catch {
            print("Error saving dream to firestore: ", error.localizedDescription)
            return nil
        }
    }
    
//    func retrieveDream() {
//        let docRef = db.collection("dreams").document("hfMdmDmZpnrmtn9wIObg")
//        
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//                // Set the archived Data
//                let archivedData = document.data()!["archivedData"] as! Data
//                self.retrievedText = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? NSAttributedString
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
    
    func convertSingleTagToDict(tag: Tag) -> [String : String] {
        var innerDict = [String : String]()
        innerDict["text"] = tag.text
        innerDict["icon"] = tag.icon
        innerDict["color"] = tag.color
        return innerDict
    }
}

struct Tag : Identifiable {
    var id: String
    
    var index: Int
    var text: String
    var icon: String
    var color: String
    
    func convertColorStringToView() -> Color {
        switch self.color{
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


