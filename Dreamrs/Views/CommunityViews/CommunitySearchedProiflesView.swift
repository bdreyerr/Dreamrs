//
//  CommunitySearchedProiflesView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/16/24.
//

import SwiftUI

struct CommunitySearchedProiflesView: View {
    
    @EnvironmentObject var communityManager: CommunityManager
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    if communityManager.searchedProfiles.isEmpty {
                        Image("sleep_face")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .opacity(0.6)
                            .padding(.top, 60)
                    }
                    
                    ForEach(communityManager.searchedProfiles) { user in
                        NavigationLink(destination: CommunityProfileView()) {
                            HStack {
                                VStack {
                                    Text(user.firstName! + " " + user.lastName!)
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 16))
                                        .fontDesign(.serif)
                                        .opacity(1.0)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("@" + user.handle!)
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 14))
                                        .fontDesign(.serif)
                                        .opacity(0.8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Spacer()
                                VStack {
                                    Text("\(user.karma!)")
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
                            communityManager.focusedProfile = user
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
}

#Preview {
    CommunitySearchedProiflesView()
        .environmentObject(CommunityManager())
}
