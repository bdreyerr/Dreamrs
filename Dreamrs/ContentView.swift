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
        ZStack {
            // check if user is logged in from userDefaults
            if let loginStatus = UserDefaults.standard.object(forKey: loginStatusKey) as? Bool {
                
                if loginStatus == false {
                    RegisterView()
                }
                
                if loginStatus == true {
                    BottomNavBar()
                        .onAppear {
                            if let userId = Auth.auth().currentUser?.uid {
                                userManager.retrieverUserFromFirestore(userId: userId)
                            } else {
                                print("The current user could not be retrieved")
                                authManager.logOut()
                            }
                        }
                    
                    if let hasUserCompletedWelcomeSurvey = userManager.user?.hasUserCompletedWelcomeSurvey {
                        if hasUserCompletedWelcomeSurvey == false {
                            WelcomeSurveyView()
                        }
                    }
                }
                
            } else {
                Text("No User default set")
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
