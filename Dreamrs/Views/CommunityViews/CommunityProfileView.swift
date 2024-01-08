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
                    
                    Text("D R E A M B O A R D")
                        .font(.system(size: 14))
                        .padding(.trailing, 20)
                    //                            .padding(.bottom, 5)
                        .font(.subheadline)
                        .bold()
                        .padding(.trailing, 40)
                }
                .padding(.bottom, 20)
                
                if let profile = communityManager.focusedProfile {
                    
                    // Full Name
                    Text(profile.firstName! + " " + profile.lastName!)
                        .font(.system(size: 20))
                        .fontDesign(.serif)
                        .bold()
                    
                    // Handle
                    Text("@" + profile.handle!)
                        .font(.system(size: 16))
                        .fontDesign(.serif)
                        .opacity(0.8)
                    
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
                                                // Remove the following locally, and in firestore.
                                                userManager.user!.following! = userManager.user!.following!.filter { $0 != profile.id! }
                                                self.isUnfollowPopupShowing.toggle()
                                                 userManager.unfollowProfile(profileId: profile.id!)
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
                                    print("User wanted to follow")
                                    userManager.user!.following!.append(profile.id!)
                                    self.isUnfollowPopupShowing = false
                                    userManager.followProfile(profileId: profile.id!)
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
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    CommunityProfileView()
        .environmentObject(CommunityManager())
}