//
//  WelcomeSurveyManager.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/15/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class WelcomeSurveyManager : ObservableObject {
    
    @Published var handle: String = ""
    @Published var userColor: String = ""
    
    @Published var errorString: String = ""
    
    @Published var isEULAShowing: Bool = false
    @Published var hasUserAcceptedEULA: Bool = false
    
    @Published var isLoadingWheelVisisble: Bool = false
    
    @Published var hasUserCompletedSurvey = true
    
    

    // Firestore
    let db = Firestore.firestore()
    
    var colorOptions = ["Black", "Red", "Blue", "Green", "Purple", "Cyan", "Yellow", "Orange"]
    
    init() {
        self.userColor = colorOptions[0]
    }
    
    func completeWelcomeSurvey() {
        self.errorString = ""
        // Blank error cases
        if self.handle == "" {
            self.errorString = "Please enter a handle"
            return
        }
        
        // Whitespace error cases
        if self.handle.contains(where: { $0.isWhitespace }) {
            self.errorString = "Handle must not contain a whitespace"
            return
        }
        
        // Character count error cases
        if self.handle.count > 30 {
            self.errorString = "Handle is too long"
            return
        }
        
        db.collection("users").whereField("handle", isEqualTo: self.handle)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: ", err.localizedDescription)
                } else {
                    for _ in querySnapshot!.documents {
                        self.errorString = "Handle is already in use"
                        return
                    }
                    
                    // Otherwise handle is not already in use, continue with the setup.
                    self.isLoadingWheelVisisble = true
                    // Get user Id from firebase Auth
                    let userId = Auth.auth().currentUser!.uid
                    
                    // All fields are valid, update database and set UserDefault
                    self.db.collection("users").document(userId).updateData([
                        "handle": self.handle,
                        "userColor": self.userColor,
                        "hasUserCompletedWelcomeSurvey": true,
                        "isUserDeleted": false,
                        "isAdmin": false
                    ]) { err in
                        if let err = err {
                            print("Error updating user fields from welcome sruvey: \(err)")
                        } else {
//                            print("User updated successfully during welcome survey!")
                        }
                    }
                }
                
            }
    }
    
    func convertColorStringToView() -> Color {
        switch self.userColor {
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
    
    var eulaText = """
    END USER LICENSE AGREEMENT (EULA) FOR DREAMRS
    
    IMPORTANT – READ CAREFULLY: This End User License Agreement ("EULA") is a legal agreement between you (either an individual or a single entity) and Benjamin Dreyer ("Licensor") for the Dreamrs software application and any associated materials (collectively, the "App"). By installing, accessing, or using the App, you agree to be bound by the terms of this EULA. If you do not agree to the terms of this EULA, do not install or use the App.

    LICENSE GRANT
    Subject to your compliance with the terms of this EULA, Licensor grants you a limited, non-exclusive, revocable, non-transferable license to download, install, and use the App for your personal, non-commercial use on a device owned or controlled by you.

    USER GENERATED CONTENT
    The App supports user-generated content ("UGC"). You retain ownership of any intellectual property rights that you hold in the UGC you create or submit through the App. By creating or submitting UGC, you grant Licensor a worldwide, royalty-free, perpetual, irrevocable, sublicensable, and transferable license to use, reproduce, distribute, prepare derivative works of, display, and perform the UGC in connection with the App and Licensor's business, including without limitation for promoting and redistributing part or all of the App.

    COLLECTION AND USE OF INFORMATION
    The App may collect and use information about you, including but not limited to, your device and identity information. By using the App, you consent to the collection and use of this information as described in the App's Privacy Policy. You acknowledge that Licensor may update the Privacy Policy from time to time, and it is your responsibility to review and familiarize yourself with any changes.

    OBJECTIONABLE CONTENT AND ABUSE
    The App prohibits the submission of objectionable content or abusive behavior by users. Objectionable content includes, but is not limited to, content that is defamatory, obscene, offensive, or violates any applicable laws. Users engaging in objectionable content or abuse may have their content deleted, and their accounts may be removed from the App.

    TERMINATION
    This license is effective until terminated. Your rights under this license will terminate automatically without notice from Licensor if you fail to comply with any term(s) of this EULA. Upon termination of the license, you must cease all use of the App and delete all copies of the App from your devices.

    DISCLAIMER OF WARRANTY
    The App is provided "as is" without any warranties of any kind, either express or implied, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, or non-infringement.

    LIMITATION OF LIABILITY
    To the extent permitted by applicable law, in no event shall Licensor be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from (i) your use or inability to use the App; (ii) any unauthorized access to or use of your information; or (iii) any third-party content or conduct.

    GOVERNING LAW
    This EULA is governed by and construed in accordance with the laws of your country and state, without regard to its conflict of law principles.

    By installing, accessing, or using the App, you acknowledge that you have read and understood this EULA and agree to be bound by its terms. If you do not agree to these terms, do not use the App.

    """
}
