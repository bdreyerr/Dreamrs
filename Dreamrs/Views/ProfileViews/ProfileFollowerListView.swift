//
//  ProfileFollowerListView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/7/24.
//

import SwiftUI

struct ProfileFollowerListView: View {
    
    @EnvironmentObject var userManager: UserManager
    @StateObject var communityManager = CommunityManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(userManager.followers) { follower in
                            NavigationLink(destination: CommunityProfileView()) {
                                HStack {
                                    VStack {
                                        Text(follower.firstName! + " " + follower.lastName!)
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 16))
                                            .fontDesign(.serif)
                                            .opacity(1.0)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("@" + follower.handle!)
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 14))
                                            .fontDesign(.serif)
                                            .opacity(0.8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Spacer()
                                    VStack {
                                        Text("\(follower.karma!)")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 16))
                                            .fontDesign(.serif)
                                            .opacity(1.0)
                                        Text("Karma")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 12))
                                            .fontDesign(.serif)
                                            .opacity(0.8)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                communityManager.focusedProfile = follower
                            })
                        }
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 20)
            }
        }
        .environmentObject(communityManager)
    }
}

#Preview {
    ProfileFollowerListView()
        .environmentObject(UserManager())
        .environmentObject(CommunityManager())
}
