import AuthenticationServices
import CryptoKit
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI


class AuthManager: UIViewController, ObservableObject {
    // This variable tracks whether or not the user will encounter the login / register screens
    @Published var isLoggedIn: Bool = false
    
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    
    // Unhashed nonce. (used for Apple sign in)
    @Published var currentNonce:String?
    @Published var request: ASAuthorizationAppleIDRequest?
    
    @Published var errorString: String = ""
    @Published var isErrorStringShowing: Bool = false
    
    // Firestore
    let db = Firestore.firestore()
    
    // The function called in the onComplete closure of the SignInWithAppleButton in the RegisterView
    func appleSignInButtonOnCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            print(authResults.credential.description)
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                
                print("full name: ", appleIDCredential.fullName ?? "no name")
                
                if let fullName = appleIDCredential.fullName {
                    if let firstName = fullName.givenName {
                        self.firstName = firstName
                    }
                    
                    if let lastName = fullName.familyName {
                        self.lastName = lastName
                    }
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                        rawNonce: nonce,
                                                                        fullName: appleIDCredential.fullName)
                
//                let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString, rawNonce: nonce)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if (error != nil) {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error?.localizedDescription as Any)
                        return
                    }
                    
                    guard let user = authResult?.user else {
                        //                        print("No user")
                        return
                    }
                    
                    // grab the email
                    if let email = user.email {
                        self.email = email
                    }
                    
                    
                    if let name = user.displayName {
                        print("display name is: ", name)
                    } else {
                        print("no display name")
                    }
                    
                    //                    print("signed in with apple")
                    //                    print("\(String(describing: user.uid))")
                    
                    
                    // Figure out if the user already has an account or is signing up for the first time (email is either blank or filled, can't be null)
                    let docRef = self.db.collection("users").whereField("email", isEqualTo: self.email)
                    docRef.getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("Error retrieving user via email: ", err)
                        } else {
                            if querySnapshot!.documents.isEmpty {
                                // No user account matches this email, create a firestore user, new user is registering
                                
                                // Create the user object (only define some fields, the user will update the rest of the info in the welcome survey)
                                let userObject = User(firstName: self.firstName, lastName: self.lastName, email: self.email, handle: "", userColor: "black", following: [user.uid], followers: [user.uid], numDreams: 0, karma: 0, pinnedDreams: [], hasUserCompletedWelcomeSurvey: false)
                                // Add the user to firestore user collection
                                let collectionRef = self.db.collection("users")
                                do {
                                    try collectionRef.document(user.uid).setData(from: userObject)
                                    //                                    print("Apple sign in user stored in firestore with new user reference: ", user.uid)
                                    
                                    self.isLoggedIn = true
                                    // Set user defaults
                                    UserDefaults.standard.set(self.isLoggedIn, forKey: loginStatusKey)
                                } catch {
                                    print("Error saving the new user to firestore")
                                }
                            } else {
                                // An existing user is signing in
                                //                                print("A current user with that same email already exists: ")
                                //                                print(querySnapshot!.documents[0].documentID)
                                
                                //                                let dataDescription = querySnapshot!.documents[0].data().map(String.init(describing:))
                                
                                
                                //                                print("The auth user id is: ")
                                if let user = Auth.auth().currentUser {
                                    print(user.uid)
                                }
                                
                                self.isLoggedIn = true
                                // Set user defaults
                                UserDefaults.standard.set(self.isLoggedIn, forKey: loginStatusKey)
                            }
                        }
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
            return
        }
        self.isLoggedIn = false
        UserDefaults.standard.set(isLoggedIn, forKey: loginStatusKey)
        UserDefaults.standard.set(false, forKey: hasUserCompletedWelcomeSurveyKey)
        //        print("The user logged out")
    }
    
    
    // Functions for apple sign in flow
    
    // Generate a random Nonce used to make sure the ID token you get was granted specifically in response to your app's authentication request.
    //Hashing function using CryptoKit
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // from https://firebase.google.com/docs/auth/ios/apple
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func deleteUser() {
        do {
            let nonce = try self.randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
          } catch {
            // In the unlikely case that nonce generation fails, show error view.
            print(error)
          }
    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
//    func performExistingAccountSetupFlows() {
//        // Prepare requests for both Apple ID and password providers.
//        let requests = [ASAuthorizationAppleIDProvider().createRequest()]
//        
//        // Create an authorization controller with the given requests.
//        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
//    
//    /// - Tag: perform_appleid_request
//    @objc
//    func handleAuthorizationAppleIDButtonPress() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
    
//    func deleteUser(userId: String) async {
//        // This action requires a recent login in firebase auth, so reauthenticate
//        
//        guard let user = Auth.auth().currentUser else {
//            print("Error getting cur user")
//            return
//        }
//        
//        do {
//            let idToken = try await user.getIDToken()
//            let nonce = self.randomNonceString()
//            
//            let credential = OAuthProvider.credential(
//                withProviderID: "apple.com",
//                idToken: idToken,
//                rawNonce: nonce
//            )
//            
//            
//            Auth.auth().currentUser!.reauthenticate(with: credential) { (authResult, error) in
//                guard error != nil else {
//                    print("error reauthenticating")
//                    return
//                }
//                // Apple user successfully re-authenticated.
//                print("reauth successful")
//                
//                // Delete the user from auth, and mark their firestore page as innactive
//                Auth.auth().currentUser!.delete() { error in
//                    if let error = error {
//                        print("error deleting auth user: ", error.localizedDescription)
//                    } else {
//                        // Update firestore page
//                        self.db.collection("users").document(userId).updateData([
//                            "isUserDeleted": true,
//                            "email": "deleted@deleted.com"
//                        ]) { err in
//                            if let err = err {
//                                print("error updating firestore page: ", err.localizedDescription)
//                            } else {
//                                self.logOut()
//                            }
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("error getting token: ", error.localizedDescription)
//        }
//        
//        
//        
//        //        // First update the user in firestore marking their account as deleted
//                self.db.collection("users").document(userId).updateData([
//                    "isUserDeleted": true
//                ]) { err in
//                    if let err = err {
//                        print("error updating user in firestore as deleted: ", err.localizedDescription)
//                    } else {
//        //                print("successfully updated user as deleted")
//                        // Delete the auth user
//                        let user = Auth.auth().currentUser
//                        user?.delete() { error in
//                            if let error = error {
//                                print("Error deleting auth user: ", error.localizedDescription)
//                                self.errorString = "Your credentials are out of date, please log out and log in again to delete your account."
//                                self.isErrorStringShowing = true
//                            } else {
//        //                        print("Auth user got deleted successfully")
//                                self.logOut()
//                            }
//                        }
//                    }
//                }
//    }
}


extension AuthManager: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a fresh Apple credential with Firebase.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                    rawNonce: nonce,
                                                                    fullName: appleIDCredential.fullName)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription as Any)
                    return
                }
                
                guard let user = authResult?.user else {
                    //                        print("No user")
                    return
                }
                
                // grab the email
                if let email = user.email {
                    self.email = email
                }
                
                
                if let name = user.displayName {
                    print("display name is: ", name)
                } else {
                    print("no display name")
                }
                
                print("we signed in okay?")
                
                // delete the account after sign in
                do {
                    
                    if let user = Auth.auth().currentUser {
                        // set bit on firestore field
                        self.db.collection("users").document(user.uid).updateData([
                            "isUserDeleted": true,
                            "email": "deleted@deleted.com"
                        ]) { err in
                            if let err = err {
                                print("error updating user in firestore as deleted: ", err.localizedDescription)
                            } else {
                                print("successfully set bit")
                                Task {
                                    try Auth.auth().revokeToken(withAuthorizationCode: String(data: appleIDCredential.authorizationCode!, encoding: .utf8)!)
                                    try user.delete()
                                    self.logOut()
                                }
                            }
                        }
                        
                    }
                    
                    
                    
                } catch {
                    print(error)
                }
                
            }
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            
        default:
            break
        }
    }
    
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print(error)
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension UIViewController {
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? AuthManager {
            loginViewController.modalPresentationStyle = .formSheet
            loginViewController.isModalInPresentation = true
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}

