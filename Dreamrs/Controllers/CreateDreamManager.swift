//
//  CreateDreamManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/6/23.
//

import Foundation
import FirebaseFirestore

class CreateDreamManager : ObservableObject {
    
    // Total text object, array of text to bool array mappings
    // [{"this is the first line that has no formatting" : [0,0,0]}, {"this line is bold" : [1,0,0]}, {"this line is underline" : [0,0,1]}]
    @Published var totalText: [FormattedText] = []
    @Published var concatTextForView: String = ""
    
    // Current text (text may be split up depending on format)
    @Published var currentText: String = ""
    // current formatting options
    @Published var currentFormat: [Bool] = [false, false, false]
    
    // Firestore
    let db = Firestore.firestore()
    
    // Enable the Bold formatting button
    func toggleBold() {
        // Add the current text and format to the totalText
        if currentText != "" {
            let currentId = self.totalText.count
            let formattedText = FormattedText(id: "\(currentId)", text: currentText, format: currentFormat)
            totalText.append(formattedText)
        }
        
        // Rest the currentText
        currentText = ""
        // Change the format
        currentFormat[0].toggle()
        
        print(totalText)
    }
    
    // Enable the Italic formatting button
    func toggleItalic() {
        // Add the current text and format to the totalText
        if currentText != "" {
            let currentId = self.totalText.count
            let formattedText = FormattedText(id: "\(currentId)", text: currentText, format: currentFormat)
            totalText.append(formattedText)
        }
        
        currentText = ""
        currentFormat[1].toggle()
        print(totalText)
    }
    
    // Enable the Underline formatting button
    func toggleUnderline() {
        // Add the current text and format to the totalText
        if currentText != "" {
            let currentId = self.totalText.count
            let formattedText = FormattedText(id: "\(currentId)", text: currentText, format: currentFormat)
            totalText.append(formattedText)
        }
        
        currentText = ""
        currentFormat[2].toggle()
        print(totalText)
    }
    
    // TODO: Decide how we grab the userId, either from view or check Auth or whatever
    func submitDream(userId: String, userHandle: String) {
        // Check the userId passed from view matches the Auth.auth().currentuser
        
        print("The total text currently looks like: ", totalText)
        
        
        let date = Date()
        let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
        
        // Create a dream object
        let dream = Dream(authorId: userId, authorHandle: userHandle, text: totalText, date: formattedDate, karma: 1)
        
        // Save the dream to firestore
        let dreamsRef = db.collection("dreams")
        do {
            let newDreamRef = try dreamsRef.addDocument(from: dream)
            print("Dream stored with new document reference: ", newDreamRef)
        }
        catch {
            print(error)
        }
    }
    
    
}

struct FormattedText : Identifiable, Codable {
    var id: String
    var text: String?
    var format: [Bool]?
    
    init(id: String, text: String, format: [Bool]) {
        self.id = id
        self.text = text
        self.format = format
      }
}
