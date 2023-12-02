//
//  ContentView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            // check if user is logged in from userDefaults
            if let loginStatus = UserDefaults.standard.object(forKey: loginStatusKey) as? Bool {
                
                // Show the register / login screen either if the loginStatus is nil, or false
                if loginStatus == false {
                    RegisterView()
                }
                
                if loginStatus == true {
                    BottomNavBar()
                }
                
            } else {
//                Text("No user default set, it should always be false or true though.")
                
                // Showing main app flow for testing
                BottomNavBar()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
