//
//  ProfileSettingsView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/24/23.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    
    @State var presentEditFirstNameAlert: Bool = false
    @State var presentEditLastNameAlert: Bool = false
    @State var presentEditHandleAlert: Bool = false
    
    @State var newFirstName: String = ""
    @State var newLastName: String = ""
    @State var newHandle: String = ""
    
    @State var confirmDelete: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Dreamrs")) {
                    Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    
                    
                    Link("Privacy Policy", destination: URL(string: "https://sites.google.com/view/dreamboard-privacy-policy/home")!)
                }
                
                Section(header: Text("Account Details")) {
                    // Email
                    HStack {
                        Text("Email: ")
                            .bold()
                        if let user = userManager.user {
                            if let email = user.email {
                                
                                Text(email)
                            }
                        }
                    }
                    
                    
                    // First Name
                    HStack {
                        Text("First Name: ")
                            .bold()
                        if let user = userManager.user {
                            if let firstName = user.firstName {
                                HStack {
                                    Text(firstName)
                                }
                            }
                        }
                        
                        // Change first name button
                        Button(action: {
                            presentEditFirstNameAlert = true
                        })
                        {
                            Image(systemName: "info.circle")
                        }
                        .alert("Edit First Name", isPresented: self.$presentEditFirstNameAlert) {
                            TextField("New First Name", text: self.$newFirstName)
                            HStack {
                                Button("Cancel", role: .cancel) {
                                    presentEditFirstNameAlert = false
                                }.foregroundColor(.red)
                                Button("Save", role: .none) {
                                    if self.newFirstName != "" {
                                        // Rate limit check
                                        if let rateLimit = userManager.processFirestoreWrite() {
                                            print(rateLimit)
                                        } else {
                                            if let err = userManager.updateUserFirstName(newFirstName: self.newFirstName) {
                                                print("error changing name: \(err)")
                                            } else {
                                                print("name change success")
                                            }
                                        }
                                    }
                                    self.presentEditFirstNameAlert = false
                                }.foregroundColor(.blue)
                            }
                        }
                        
                    }
                    // Last Name
                    HStack {
                        Text("Last Name: ")
                            .bold()
                        if let user = userManager.user {
                            if let lastName = user.lastName {
                                HStack {
                                    Text(lastName)
                                }
                            }
                        }
                        
                        // Change last name button
                        Button(action: {
                            presentEditLastNameAlert = true
                        })
                        {
                            Image(systemName: "info.circle")
                        }
                        .alert("Edit Last Name", isPresented: self.$presentEditLastNameAlert) {
                            TextField("New Last Name", text: self.$newLastName)
                            HStack {
                                Button("Cancel", role: .cancel) {
                                    presentEditLastNameAlert = false
                                }.foregroundColor(.red)
                                Button("Save", role: .none) {
                                    if self.newLastName != "" {
                                        // Rate limit check
                                        if let rateLimit = userManager.processFirestoreWrite() {
                                            print(rateLimit)
                                        } else {
                                            if let err = userManager.updateUserLastName(newLastName: self.newLastName) {
                                                print("error changing name: \(err)")
                                            } else {
                                                print("name change success")
                                            }
                                        }
                                    }
                                    self.presentEditLastNameAlert = false
                                }.foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Community")) {
                    // Display Name
                    HStack {
                        Text("Handle: ")
                            .bold()
                        if let user = userManager.user {
                            if let handle = user.handle {
                                HStack {
                                    Text(handle)
                                }
                            }
                        }
                        
                        // Change handle button
                        Button(action: {
                            presentEditHandleAlert = true
                        })
                        {
                            Image(systemName: "info.circle")
                        }
                        .alert("Edit Handle", isPresented: self.$presentEditHandleAlert) {
                            TextField("New Handle", text: self.$newHandle)
                                .textInputAutocapitalization(.never)
                            HStack {
                                Button("Cancel", role: .cancel) {
                                    presentEditHandleAlert = false
                                }.foregroundColor(.red)
                                Button("Save", role: .none) {
                                    if self.newHandle != "" {
                                        // Rate limit check
                                        if let rateLimit = userManager.processFirestoreWrite() {
                                            print(rateLimit)
                                        } else {
                                            if let err = userManager.updateUserHandle(newHandle: self.newHandle) {
                                                print("error changing name: \(err)")
                                            } else {
                                                print("name change success")
                                            }
                                        }
                                    }
                                    self.presentEditHandleAlert = false
                                }.foregroundColor(.blue)
                            }
                        }
                        
                    }
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        // Sign out of account
                        authManager.logOut()
                    }) {
                        Text("Sign Out")
                    }
                    Button(action: {
                        // Delete Account
                        self.confirmDelete = true
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }.alert("Confirm you want to delete your account permanently?", isPresented: self.$confirmDelete) {
                        Button("Confirm") {
                            if let user = userManager.user {
                                authManager.deleteUser(userId: user.id!)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                    // Error string
                    .alert(authManager.errorString, isPresented: $authManager.isErrorStringShowing) {
                        Button("Ok", role: .cancel) { }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileSettingsView()
        .environmentObject(UserManager())
        .environmentObject(AuthManager())
}
