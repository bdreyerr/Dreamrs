//
//  ProfileMainView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct ProfileMainView: View {
    @State var isProfileSettingsPopupShowing: Bool = false
    
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Logo and settings
                    HStack {
                        Image("home_logo")
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        Text("D R E A M B O A R D")
                            .font(.system(size: 14))
                            .padding(.trailing, 20)
//                            .padding(.bottom, 5)
                            .font(.subheadline)
                            .bold()
                            .padding(.trailing, 40)
                        
                        Button(action: {
                            isProfileSettingsPopupShowing = true
                        }) {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                        }.sheet(isPresented: $isProfileSettingsPopupShowing) {
                            ProfileSettingsView()
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Full Name
                    Text("Ben Dreyer")
                        .font(.system(size: 20))
                        .fontDesign(.serif)
                        .bold()
                    
                    // Handle
                    Text("@bendreyer")
                        .font(.system(size: 16))
                        .fontDesign(.serif)
                        .opacity(0.8)
                    
                    // Dream Stats
                    HStack {
                        // Dreams Recorded
                        VStack {
                            if let user = userManager.user {
                                if let numDreams = user.numDreams {
                                    Text("\(numDreams)")
                                        .font(.system(size: 18))
                                        .fontDesign(.serif)
                                        .bold()
                                } else {
                                    Text("34")
                                        .font(.system(size: 18))
                                        .fontDesign(.serif)
                                        .bold()
                                }
                            } else {
                                Text("34")
                                    .font(.system(size: 18))
                                    .fontDesign(.serif)
                                    .bold()
                            }
                            Text("Dreams")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .opacity(0.8)
                        }
                        
                        // Dream Karma
                        VStack {
                            if let user = userManager.user {
                                if let karma = user.karma {
                                    Text("\(karma)")
                                        .font(.system(size: 18))
                                        .fontDesign(.serif)
                                        .bold()
                                } else {
                                    Text("1")
                                        .font(.system(size: 18))
                                        .fontDesign(.serif)
                                        .bold()
                                }
                            } else {
                                Text("1")
                                    .font(.system(size: 18))
                                    .fontDesign(.serif)
                                    .bold()
                            }
                            Text("Karma")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .opacity(0.8)
                        }
                        
                        
                        // Friends
                        VStack {
                            if let user = userManager.user {
                                if let followers = user.followers {
                                    Text("\(followers.count)")
                                        .font(.system(size: 18))
                                        .fontDesign(.serif)
                                        .bold()
                                } else {
                                    Text("0")
                                        .font(.system(size: 18))
                                        .fontDesign(.serif)
                                        .bold()
                                }
                            } else {
                                Text("0")
                                    .font(.system(size: 18))
                                    .fontDesign(.serif)
                                    .bold()
                            }
                            
                            Text("Followers")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .opacity(0.8)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    
                    // Pinned Dreams
                    VStack {
                        Text("Pinned Dreams")
                            .font(.system(size: 18))
                            .fontDesign(.serif)
                            .bold()
                        
                        NavigationLink(destination: SingleDream()) {
                            HStack {
                                VStack {
                                    Text("Driving with Dad, looking for puppies")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14, design: .serif))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                        Text("Nov 18th, 2023")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 14, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Image("dad_dog")
                                    .resizable()
                                    .frame(width: 100, height: 60)
                                    .clipShape(Circle())
                            }
                        }
                        
                        NavigationLink(destination: SingleDream()) {
                            HStack {
                                VStack {
                                    Text("Skating through a mall on ice skates")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14, design: .serif))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                        Text("Jan 18th, 2021")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 14, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Image("dream2")
                                    .resizable()
                                    .frame(width: 100, height: 60)
                                    .clipShape(Circle())
                            }
                        }
                        
                        NavigationLink(destination: SingleDream()) {
                            HStack {
                                VStack {
                                    Text("Swimming with mermaids")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 14, design: .serif))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                        Text("Oct 9th, 2023")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 14, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Image("dream3")
                                    .resizable()
                                    .frame(width: 100, height: 60)
                                    .clipShape(Circle())
                            }
                        }
                        
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

#Preview {
    ProfileMainView()
        .environmentObject(UserManager())
}
