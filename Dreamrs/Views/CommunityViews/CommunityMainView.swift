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
    
    var body: some View {
        NavigationView {
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
                        //                            .padding(.bottom, 15)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom, 20)
                    
                    // Following vs. For You
                    HStack {
                        Button(action: {
                            communityManager.selectedTrafficSlice = communityManager.trafficSlices[0]
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
                                        communityManager.retrieveDreams(userId: user.id!, following: user.following!)
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
            }
        }
        .environmentObject(communityManager)
        .onAppear {
            if let user = userManager.user {
                print("user available")
                if let following = user.following {
                    communityManager.retrieveDreams(userId: user.id!, following: following)
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
}


struct CommunityDream : View {
    
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var userManager: UserManager
    
    var dream: Dream
    var title: String
    var handle: String
    var date: String
    var karma: Int
    
    @State var isDreamUpvoted: Bool = false
    @State var isDreamDownvoted: Bool = false
    
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
                            .foregroundColor(communityManager.getColorForHandle())
                            .bold()
                            .font(.system(size: 16, design: .serif))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(date)
                            .foregroundStyle(.gray)
                            .font(.system(size: 14, design: .serif))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Image(communityManager.randomImage())
                        .resizable()
                        .frame(width: 100, height: 60)
                        .clipShape(Circle())
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(minWidth: 10, maxWidth: 80, minHeight: 25)
                        .overlay {
                            HStack {
                                Button(action: {
                                    if let user = userManager.user {
                                        if !self.isDreamUpvoted {
                                            communityManager.processKarmaVote(userId: user.id!, dream: self.dream, isUpvote: true)
                                            self.isDreamUpvoted = true
                                            self.isDreamDownvoted = false
                                        }
                                    }
                                }) {
                                    Image(systemName: "arrowshape.up")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(self.isDreamUpvoted ? .orange : .black)
                                }
                                
                                Text("\(karma)")
                                    .foregroundStyle(self.isDreamUpvoted ? .orange : .black)
                                
                                Divider()
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    if let user = userManager.user {
                                        if !self.isDreamDownvoted {
                                            communityManager.processKarmaVote(userId: user.id!, dream: self.dream, isUpvote: false)
                                            self.isDreamDownvoted = true
                                            self.isDreamUpvoted = false
                                        }
                                    }
                                }) {
                                    Image(systemName: "arrowshape.down")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(self.isDreamDownvoted ? .blue : .black)
                                }
                            }
                        }
                    Spacer()
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
