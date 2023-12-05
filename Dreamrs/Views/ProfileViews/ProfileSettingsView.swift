//
//  ProfileSettingsView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/24/23.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Dreamboard")) {
                    Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    
                    
                    Link("Privacy Policy", destination: URL(string: "https://sites.google.com/view/radiant-privacy-policy/home")!)
                }
                
                Section(header: Text("Account Details")) {
                    // Email
                    HStack {
                        Text("Email: ")
                            .bold()
                        Text("bendfunk@gmail.com")
                    }
                    
                    // Birthday
                    HStack {
                        Text("Birthday: ")
                            .bold()
                        Text("08/04/1999")
                    }
                    
                    // Name
                    HStack {
                        Text("Name: ")
                            .bold()
                        Text("Ben")
                    }
                }
                
                Section(header: Text("Community Forum")) {
                    // Display Name
                    HStack {
                        Text("Display Name: ")
                            .bold()
                    }
                }
                
                Section(header: Text("Account")) {
                    Button {
                    } label: {
                        Text("Restore Purchases")
                    }
                    Button(action: {
                        // Sign out of account
                        authManager.logOut()
                    }) {
                        Text("Sign Out")
                    }
                    Button(action: {
                        // Delete Account
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileSettingsView()
}
