//
//  ContentView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct ContentView: View {
    @StateObject var authManager = AuthManager()
    @StateObject var userManager = UserManager()
    
    var body: some View {
        VStack {
            // check if user is logged in from userDefaults
            if let loginStatus = UserDefaults.standard.object(forKey: loginStatusKey) as? Bool {
                
                // Show the register / login screen either if the loginStatus is nil, or false
                if loginStatus == false {
//                    Text("not logged in")
                    RegisterView()
                }
                
                if loginStatus == true {
//                    Text("logged in")
                    BottomNavBar()
                        .onAppear {
                            if let userId = Auth.auth().currentUser?.uid {
                                userManager.retrieverUserFromFirestore(userId: userId)
                            } else {
                                print("The current user could not be retrieved")
                                authManager.logOut()
                            }
                        }
                }
                
            } else {
                RegisterView()
                
                // Showing main app flow for testing
//                BottomNavBar()
            }
        }
        .environmentObject(authManager)
        .environmentObject(userManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
