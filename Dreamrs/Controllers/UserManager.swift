//
//  UserManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/4/23.
//

import Foundation
import FirebaseFirestore

class UserManager : ObservableObject {
    // ToDo
    // Rate Limiting
    // Firebase Storage
    
    // Firestore
    let db = Firestore.firestore()
    @Published var user: User?
    
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
}
