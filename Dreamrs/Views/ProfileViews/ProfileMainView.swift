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
    @StateObject var homeManager = HomeManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Logo and settings
                    HStack {
                        Image("home_logo")
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        Text("D R E A M R S")
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
                    
                    if let user = userManager.user {
                        if let firstName = user.firstName {
                            if let lastName = user.lastName {
                                // Full Name
                                Text(firstName + " " + lastName)
                                    .font(.system(size: 20))
                                    .fontDesign(.serif)
                                    .bold()
                            }
                        }
                        
                        if let handle = user.handle {
                            // Handle
                            Text("@" + handle)
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .foregroundStyle(userManager.convertColorStringToView())
                                .opacity(1.0)
                        }
                    }
                    
                    
                    
                    
                    
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
                        NavigationLink(destination: ProfileFollowerListView()) {
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
                        .foregroundStyle(Color.black)
                        .simultaneousGesture(TapGesture().onEnded {
                            userManager.loadFollowers()
                        })
                        
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    
                    // Pinned Dreams
                    VStack {
                        Text("Pinned Dreams")
                            .font(.system(size: 18))
                            .fontDesign(.serif)
                            .bold()
                        
                        ForEach(userManager.pinnedDreams) { dream in
                            PinnedDream(dream: dream)
                        }
                        
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .environmentObject(homeManager)
        .onAppear {
            userManager.loadPinnedDreams(isRefresh: false)
        }
    }
}

#Preview {
    ProfileMainView()
        .environmentObject(UserManager())
        .environmentObject(HomeManager())
}


struct PinnedDream : View {
    
    var dream: Dream
    
    @EnvironmentObject var homeManager: HomeManager
    @EnvironmentObject var userManager: UserManager
    
    var body : some View {
        NavigationLink(destination: SingleDream()) {
            HStack {
                VStack {
                    Text(dream.title!)
                        .foregroundStyle(.black)
                        .font(.system(size: 14, design: .serif))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(dream.date!)
                            .foregroundStyle(.gray)
                            .font(.system(size: 14, design: .serif))
                            .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // dream image
                if let image = userManager.pinnedDreamImages[dream.id!] {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 60)
                        .clipShape(Circle())
                } else {
//                    Image(homeManager.randomImage())
//                        .resizable()
//                        .frame(width: 100, height: 60)
//                        .clipShape(Circle())
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            homeManager.displayDream(dream: self.dream)
        })
    }
}
