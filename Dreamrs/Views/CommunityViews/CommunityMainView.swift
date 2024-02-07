//
//  CommunityMainView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct CommunityMainView: View {
    
    @StateObject var communityManager = CommunityManager()
    @EnvironmentObject var userManager: UserManager
    
    @StateObject var adminManager = AdminManager()
    
    var body: some View {
        NavigationView {
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
                        //                            .padding(.bottom, 15)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom, 20)
                    
                    // Following vs. For You
                    HStack {
                        
                        // Admin add posts
                        if let user = userManager.user {
                            if let isAdmin = user.isAdmin {
                                if isAdmin {
                                    Button(action: {
                                        adminManager.generateRandomDreamsForForYouPage()
                                    }) {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color.green)
                                    }
                                }
                            }
                        }
                        
                        if !communityManager.isSearchBarShowing {
                            Button(action: {
                                communityManager.selectedTrafficSlice = communityManager.trafficSlices[0]
                                if let user = userManager.user {
                                    communityManager.retrieveDreams(userId: user.id!, following: user.following!, isInfiniteScrollRequest: false, blockedUsers: user.blockedUsers ?? [:])
                                }
                                
                            }) {
                                
                                if communityManager.selectedTrafficSlice == communityManager.trafficSlices[0] {
                                    Text("Following")
                                        .font(.system(size: 16))
                                        .fontDesign(.serif)
                                        .bold()
                                        .foregroundColor(.black)
                                } else {
                                    Text("Following")
                                        .font(.system(size: 16))
                                        .fontDesign(.serif)
                                        .opacity(0.5)
                                        .foregroundColor(.black)
                                }
                                
                            }
                            
                            Button(action: {
                                communityManager.selectedTrafficSlice = communityManager.trafficSlices[1]
                                if let user = userManager.user {
                                    communityManager.retrieveDreams(userId: user.id!, following: user.following!, isInfiniteScrollRequest: false, blockedUsers: user.blockedUsers ?? [:])
                                }
                            }) {
                                if communityManager.selectedTrafficSlice == communityManager.trafficSlices[1] {
                                    Text("For You")
                                        .font(.system(size: 16))
                                        .fontDesign(.serif)
                                        .bold()
                                        .foregroundColor(.black)
                                } else {
                                    Text("For You")
                                        .font(.system(size: 16))
                                        .fontDesign(.serif)
                                        .opacity(0.5)
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Button(action: {
                                communityManager.isSearchBarShowing = true
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 20, height: 20)
    //                                .frame(maxWidth: .infinity, alignment: .trailing)
                                    .foregroundStyle(Color.black)
                            }
                            .offset(x: 80)
                        } else {
                            
                            
                            
                            
                            HStack {
                                // Text field
                                TextField("User Handle", text: $communityManager.searchText)
                                    .textInputAutocapitalization(.never)
                                    .padding(10) // Add some padding for better visual spacing
                                    .background(Color.clear) // Make the text field background transparent
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25) // Define the shape of the border
                                            .stroke(Color.black, lineWidth: 1) // Set the border color and width
                                    )
                                    .padding(.leading, 80)
                                
                                
                                // Submit button
                                if communityManager.searchText != "" {
                                    
                                    NavigationLink(destination: CommunitySearchedProiflesView()) {
                                        Image(systemName: "arrow.right.circle")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .clipShape(Circle())
                                            .foregroundStyle(Color.green)
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        communityManager.searchCommunityProfiles()
                                    })
                                    
                                }
                                
                                // Cancel button
                                Button(action: {
                                    communityManager.isSearchBarShowing = false
                                    communityManager.searchText = ""
                                }) {
                                    Image(systemName: "x.circle")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                        .foregroundStyle(Color.red)
                                }
                                
                            }
                            .padding(.trailing, 80)
                        }
                        
                        
                        
                        
                    }
                    .padding(.bottom, 10)
                    
                    HStack {
                        Menu {
                            Picker(selection: $communityManager.selectedTimeFilter) {
                                ForEach(communityManager.timeFilters, id: \.self) { value in
                                    Text(value)
                                        .tag(value)
                                        .font(.system(size: 16, design: .serif))
                                        .accentColor(.black)
                                        .bold()
                                    
                                }
                            } label: {}
                                .accentColor(.black)
                                .padding(.leading, -12)
                                .font(.system(size: 16, design: .serif))
                                .onChange(of: communityManager.selectedTimeFilter) { newValue in
                                    if let user = userManager.user {
                                        communityManager.retrieveDreams(userId: user.id!, following: user.following!, isInfiniteScrollRequest: false, blockedUsers: user.blockedUsers ?? [:])
                                    }
                                    
                                }
                        } label: {
                            HStack {
                                Text(communityManager.selectedTimeFilter)
                                    .font(.system(size: 16, design: .serif))
                                    .accentColor(.black)
                                    .bold()
                                Image(systemName: "arrowtriangle.down.fill")
                                    .resizable()
                                    .frame(width: 12, height: 6)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 15)
                    
                    // Following vs For You
                    if communityManager.selectedTrafficSlice == communityManager.trafficSlices[0] {
                        CommunityFollowingView()
                    } else if communityManager.selectedTrafficSlice == communityManager.trafficSlices[1] {
                        CommunityForYouView()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.bottom, 25)
            }
        }
        .environmentObject(communityManager)
        .environmentObject(adminManager)
        .onAppear {
            if let user = userManager.user {
                print("user available")
                if let following = user.following {
                    communityManager.retrieveDreams(userId: user.id!, following: following, isInfiniteScrollRequest: false, blockedUsers: user.blockedUsers ?? [:])
                } else {
                    print("following not available")
                }
            } else {
                print("user not available")
            }
        }
    }
}

#Preview {
    CommunityMainView()
    //        .environmentObject(CommunityManager())
        .environmentObject(UserManager())
        .environmentObject(AdminManager())
}


struct CommunityDream : View {
    
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var userManager: UserManager
    
    var dream: Dream
    var title: String
    var handle: String
    var date: String
    var karma: Int
    
    var body : some View {
        NavigationLink(destination: SingleCommunityDream()) {
            VStack {
                HStack {
                    VStack {
                        Text(title)
                            .foregroundStyle(.black)
                            .font(.system(size: 16, design: .serif))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("@" + handle)
//                            .foregroundStyle(.blue)
                            .foregroundColor(communityManager.convertStringToColor(color: dream.authorColor!))
                            .bold()
                            .font(.system(size: 16, design: .serif))
                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(/*@START_MENU_TOKEN@*/EdgeInsets()/*@END_MENU_TOKEN@*/)
                        
                        // 18+ indicated
                        if let hasAdultContent = dream.hasAdultContent {
                            if hasAdultContent {
                                Text("18+")
                                    .foregroundStyle(Color.red)
                                    .bold()
                                    .font(.system(size: 13, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        Text(date)
                            .foregroundStyle(.gray)
                            .font(.system(size: 14, design: .serif))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Dream Image
                    if let image = communityManager.retrievedImages[dream.id!] {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 100, height: 60)
                            .clipShape(Circle())
                    }
                }
                
                // Karma Vote button (only show if post is not yours)
                if let user = userManager.user {
                    if dream.authorId! == user.id {
                        HStack {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(minWidth: 10, maxWidth: 40, minHeight: 25)
                                .overlay {
                                    Text("\(karma)")
                                        .foregroundStyle(.orange)
                                }
                            Spacer()
                        }
                    } else {
                        HStack {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(minWidth: 10, maxWidth: 80, minHeight: 25)
                                .overlay {
                                    HStack {
                                        Button(action: {
                                            if let user = userManager.user {
                                                // Rate limiting check
                                                if let rateLimit = userManager.processFirestoreWrite() {
                                                    print(rateLimit)
                                                } else {
                                                    communityManager.processKarmaVote(userId: user.id!, dream: self.dream, isUpvote: true)
                                                }
                                            }
                                        }) {
                                            if !communityManager.localKarmaVotes.keys.contains(dream.id!) {
                                                Image(systemName: "arrowshape.up")
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.black)
                                            } else if communityManager.localKarmaVotes[dream.id!] == true {
                                                Image(systemName: "arrowshape.up")
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.orange)
                                            } else {
                                                Image(systemName: "arrowshape.up")
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        
                                        // different colors based on local votes
                                        if !communityManager.localKarmaVotes.keys.contains(dream.id!) {
                                            Text("\(karma)")
                                                .foregroundStyle(.black)
                                        } else if communityManager.localKarmaVotes[dream.id!] == true {
                                            Text("\(karma + 1)")
                                                .foregroundStyle(.orange)
                                        } else {
                                            Text("\(karma - 1)")
                                                .foregroundStyle(.blue)
                                        }
                                        
                                        
                                        Divider()
                                            .foregroundColor(.black)
                                        
                                        Button(action: {
                                            if let user = userManager.user {
                                                // Rate limiting check
                                                if let rateLimit = userManager.processFirestoreWrite() {
                                                    print(rateLimit)
                                                } else {
                                                    communityManager.processKarmaVote(userId: user.id!, dream: self.dream, isUpvote: false)
                                                }
                                            }
                                        }) {
                                            if !communityManager.localKarmaVotes.keys.contains(dream.id!) {
                                                Image(systemName: "arrowshape.down")
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.black)
                                            } else if communityManager.localKarmaVotes[dream.id!] == true {
                                                Image(systemName: "arrowshape.down")
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.black)
                                            } else {
                                                Image(systemName: "arrowshape.down")
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            Spacer()
                        }
                    }
                }
                
//                Rectangle()
//                    .frame(height: 0.5) // Adjust height as needed
//                    .foregroundColor(.gray)
//                    .padding(.trailing, 20)
            }
            .padding(.bottom, 10)
        }
        .simultaneousGesture(TapGesture().onEnded {
            communityManager.displayDream(dream: self.dream)
        })
    }
}
