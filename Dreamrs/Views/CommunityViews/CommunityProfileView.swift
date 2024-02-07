//
//  CommunityProfileView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/7/24.
//

import SwiftUI

struct CommunityProfileView: View {
    
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var userManager: UserManager
    
    @State var isUnfollowPopupShowing: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                // Logo
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
                }
                .padding(.bottom, 20)
                
                if let profile = communityManager.focusedProfile {
                    
                    // Account deactivated status
                    if let isDeletedProfile = profile.isUserDeleted {
                        if isDeletedProfile {
                            Text("User Innactive")
                                .font(.system(size: 18))
                                .fontDesign(.serif)
                                .bold()
                                .foregroundStyle(Color.red)
                        }
                    }
                    
                    // Blocking user
                    
                    if let user = userManager.user {
                        if let blockedUsers = user.blockedUsers {
                            if let _ = blockedUsers[profile.id!] {
                                // User is being blocked
                                Button(action: {
                                    communityManager.isUnblockUserMenuShowing = true
                                }) {
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .stroke(Color.red, lineWidth: 1) // red border
                                        .background(Color.clear) // Clear background
                                        .frame(width: 250, height: 40)
                                        .overlay {
                                            HStack {
                                                Text("This user is being blocked")
                                                    .foregroundStyle(Color.red)
                                                    .font(.system(size: 18))
                                                    .fontDesign(.serif)
                                                
                                                Image(systemName: "arrowtriangle.down.fill")
                                                    .resizable()
                                                    .frame(width: 12, height: 6)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    
                                }
                                .alert("Would you like to unblock this user?", isPresented: $communityManager.isUnblockUserMenuShowing) {
                                    Button("Confirm") {
                                        if let user = userManager.user {
                                            // rate limit
                                            if let rateLimit = userManager.processFirestoreWrite() {
                                                print(rateLimit)
                                            } else {
                                                if let profile = communityManager.focusedProfile {
                                                    
                                                    Task {
                                                        let newBlockedUsers = await userManager.unblockUser(blockedUserId: profile.id!)
                                                        
                                                        // Refresh pulled dreams to get add the unblocked user's posts back
                                                        communityManager.clearDreams()
                                                        communityManager.retrieveDreams(userId: user.id!, following: user.following!, isInfiniteScrollRequest: false, blockedUsers: newBlockedUsers)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Button("Cancel", role: .cancel) { }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    
                    
                    HStack {
                        // Full Name
                        Text(profile.firstName! + " " + profile.lastName!)
                            .font(.system(size: 20))
                            .fontDesign(.serif)
                            .bold()
                        
                        // Block User
                        if let user = userManager.user {
                            if let blockedUsers = user.blockedUsers {
                                if let _ = blockedUsers[profile.id!] {
                                } else {
                                    // Blocked user map exists, but the current user isn't being blocked
                                    Button(action: {
                                        communityManager.isBlockUserMenuShowing = true
                                    }) {
                                        Image(systemName: "exclamationmark.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color.black)
                                    }
                                    .alert("Would you like to block this user?", isPresented: $communityManager.isBlockUserMenuShowing) {
                                        Button("Confirm") {
                                            if let user = userManager.user {
                                                // rate limit
                                                if let rateLimit = userManager.processFirestoreWrite() {
                                                    print(rateLimit)
                                                } else {
                                                    if let profile = communityManager.focusedProfile {
                                                        
                                                        Task {
                                                            let newBlockedUsers = await userManager.blockUser(blockedUserId: profile.id!)
                                                            
                                                            // Refresh pulled dreams to get rid of the blocked user's posts
                                                            communityManager.clearDreams()
                                                            communityManager.retrieveDreams(userId: user.id!, following: user.following!, isInfiniteScrollRequest: false, blockedUsers: newBlockedUsers)
                                                        }
                                                        
                                                        
                                                        
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                        
                                        Button("Cancel", role: .cancel) { }
                                    }
                                }
                            } else {
                                // Or the blocked user list doesn't exist yet (the user hasn't yet blocked anyone
                                Button(action: {
                                    communityManager.isBlockUserMenuShowing = true
                                }) {
                                    Image(systemName: "exclamationmark.circle")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.black)
                                }
                                .alert("Would you like to block this user?", isPresented: $communityManager.isBlockUserMenuShowing) {
                                    Button("Confirm") {
                                        if let user = userManager.user {
                                            // rate limit
                                            if let rateLimit = userManager.processFirestoreWrite() {
                                                print(rateLimit)
                                            } else {
                                                if let profile = communityManager.focusedProfile {
                                                    
                                                    Task {
                                                        let newBlockedUsers = await userManager.blockUser(blockedUserId: profile.id!)
                                                        
                                                        // Refresh pulled dreams to get rid of the blocked user's posts
                                                        communityManager.clearDreams()
                                                        communityManager.retrieveDreams(userId: user.id!, following: user.following!, isInfiniteScrollRequest: false, blockedUsers: newBlockedUsers)
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    Button("Cancel", role: .cancel) { }
                                }
                            }
                        }
                    }

                    // Handle
                    Text("@" + profile.handle!)
                        .font(.system(size: 16))
                        .fontDesign(.serif)
                        .opacity(1.0)
                        .foregroundStyle(communityManager.convertStringToColor(color: profile.userColor!))
                    
                    // Dream Stats
                    HStack {
                        // Dreams Recorded
                        VStack {
                            Text("\(profile.numDreams!)")
                                .font(.system(size: 18))
                                .fontDesign(.serif)
                                .bold()
                            
                            
                            Text("Dreams")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .opacity(0.8)
                        }
                        
                        // Dream Karma
                        VStack {
                            Text("\(profile.karma!)")
                                .font(.system(size: 18))
                                .fontDesign(.serif)
                                .bold()
                            
                            Text("Karma")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .opacity(0.8)
                        }
                        
                        // Friends
                        VStack {
                            
                            Text("\(profile.followers!.count)")
                                .font(.system(size: 18))
                                .fontDesign(.serif)
                                .bold()
                            
                            
                            Text("Followers")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .opacity(0.8)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                    
                    // Follow / Unfollow
                    if let user = userManager.user {
                        if var following = user.following {
                            if following.contains(profile.id!) {
                                Button(action: {
                                    self.isUnfollowPopupShowing.toggle()
                                }) {
                                    VStack {
                                        ZStack {
                                            
                                            RoundedRectangle(cornerRadius: 25.0)
                                                .stroke(Color.black, lineWidth: 1) // Black border
                                                .background(Color.clear) // Clear background
                                                .frame(width: 120, height: 40)
                                            HStack {
                                                Text("Following")
                                                    .foregroundColor(.black) // Black text
                                                    .font(.system(size: 16))
                                                    .fontDesign(.serif)
                                                Image(systemName: "arrowtriangle.down.fill")
                                                    .resizable()
                                                    .frame(width: 12, height: 6)
                                                    .foregroundColor(.black)
                                                
                                            }
                                        }
                                        if self.isUnfollowPopupShowing {
                                            Button(action: {
                                                // Rate limiting check
                                                if let rateLimit = userManager.processFirestoreWrite() {
                                                    print(rateLimit)
                                                } else {
                                                    // Remove the following locally, and in firestore.
                                                    userManager.user!.following! = userManager.user!.following!.filter { $0 != profile.id! }
                                                    self.isUnfollowPopupShowing.toggle()
                                                     userManager.unfollowProfile(profileId: profile.id!)
                                                }
                                            }) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 25.0)
                                                        .stroke(Color.red, lineWidth: 1) // Black border
                                                        .background(Color.clear) // Clear background
                                                        .frame(width: 100, height: 30)
                                                    
                                                    Text("Unfollow")
                                                        .foregroundColor(.red) // Black text
                                                        .font(.system(size: 14))
                                                        .fontDesign(.serif)
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                .padding(.bottom, 40)
                            } else {
                                Button(action: {
                                    
                                    // Rate limiting check
                                    if let rateLimit = userManager.processFirestoreWrite() {
                                        print(rateLimit)
                                    } else {
//                                        print("User wanted to follow")
                                        userManager.user!.following!.append(profile.id!)
                                        self.isUnfollowPopupShowing = false
                                        userManager.followProfile(profileId: profile.id!)
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .stroke(Color.black, lineWidth: 1) // Black border
                                            .frame(width: 120, height: 40)
                                            .background(Color.clear) // Clear background
                                        Text("Follow")
                                            .padding()
                                            .foregroundColor(.black) // Black text
                                            .font(.system(size: 16))
                                            .fontDesign(.serif)
                                    }
                                }
                                .padding(.bottom, 40)
                            }
                        }
                    }
                    
                    
                    
                    // Pinned Dreams
                    VStack {
                        Text("Pinned Dreams")
                            .font(.system(size: 18))
                            .fontDesign(.serif)
                            .bold()
                        
                        
                        ForEach(communityManager.focusedProfilesPinnedDreams) { dream in
                            CommunityPinnedDream(dream: dream)
                        }
                        
//                        NavigationLink(destination: SingleDream()) {
//                            HStack {
//                                VStack {
//                                    Text("Swimming with mermaids")
//                                        .foregroundStyle(.black)
//                                        .font(.system(size: 14, design: .serif))
//                                        .multilineTextAlignment(.leading)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                    
//                                    Text("Oct 9th, 2023")
//                                        .foregroundStyle(.gray)
//                                        .font(.system(size: 14, design: .serif))
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                }
//                                
//                                Image("dream3")
//                                    .resizable()
//                                    .frame(width: 100, height: 60)
//                                    .clipShape(Circle())
//                            }
//                        }
                        
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
                    
                }
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            
        }
    }
}

#Preview {
    CommunityProfileView()
        .environmentObject(CommunityManager())
}


struct CommunityPinnedDream : View {
    
    @EnvironmentObject var communityManager: CommunityManager
    
    var dream: Dream
    
    var body : some View {
        NavigationLink(destination: SingleCommunityDream()) {
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
                
                
                if let image = communityManager.retrievedImages[dream.id!] {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 60)
                        .clipShape(Circle())
                }
                
//                Image(communityManager.randomImage())
//                    .resizable()
//                    .frame(width: 100, height: 60)
//                    .clipShape(Circle())
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            communityManager.displayDream(dream: self.dream)
        })
        .onAppear {
            communityManager.retrieveDreamImage(dream: self.dream)
        }
    }
}
