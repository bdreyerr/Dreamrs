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
}
