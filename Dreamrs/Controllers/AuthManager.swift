import AuthenticationServices
import CryptoKit
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI


class AuthManager: ObservableObject {
    // This variable tracks whether or not the user will encounter the login / register screens
    @Published var isLoggedIn: Bool = false
    
    @Published var email = ""
    
    // Unhashed nonce. (used for Apple sign in)
    @Published var currentNonce:String?
    
    // Firestore
    let db = Firestore.firestore()
    
    // The function called in the onComplete closure of the SignInWithAppleButton in the RegisterView
    func appleSignInButtonOnCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
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
                    
                    print("signed in with apple")
                    print("\(String(describing: user.uid))")
                    self.isLoggedIn = true
                    
                    // Set user defaults
                    UserDefaults.standard.set(self.isLoggedIn, forKey: loginStatusKey)
                    
                    
                    // Figure out if the user already has an account or is signing up for the first time (email is either blank or filled, can't be null)
                    let docRef = self.db.collection("users").whereField("email", isEqualTo: self.email)
                    docRef.getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("Error retrieving user via email: ", err)
                        } else {
                            if querySnapshot!.documents.isEmpty {
                                // No user account matches this email, create a firestore user, new user is registering
                                
                                // Create the user object (only define some fields, the user will update the rest of the info in the welcome survey)
                                let userObject = User(email: self.email, following: [user.uid], followers: [user.uid], numDreams: 0, karma: 0, pinnedDreams: [])
                                // Add the user to firestore user collection
                                let collectionRef = self.db.collection("users")
                                do {
                                    try collectionRef.document(user.uid).setData(from: userObject)
                                    print("Apple sign in user stored in firestore with new user reference: ", user.uid)
                                } catch {
                                    print("Error saving the new user to firestore")
                                }
                            } else {
                                // An existing user is signing in
                                print("A current user with that same email already exists: ")
                                print(querySnapshot!.documents[0].documentID)
                                
                                print("The auth user id is: ")
                                if let user = Auth.auth().currentUser {
                                    print(user.uid)
                                }
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
        print("The user logged out")
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
}
