//
//  SingleCommunityDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/4/24.
//

import SwiftUI

struct SingleCommunityDream: View {
    
    @EnvironmentObject var communityManager: CommunityManager
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        ZStack {
            ScrollView {
                if let dream = communityManager.focusedDream {
                    VStack {
                        // Date
                        HStack {
                            Text(dream.date!)
                                .opacity(0.7)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }
                        .padding(.top, 10)
                        
                        // Dream Title
                        HStack {
                            Text(dream.title!)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }

                        // Author Handle
                        NavigationLink(destination: CommunityProfileView()) {
                            Text("@" + dream.authorHandle!)
                                .font(.system(size: 20, design: .serif))
                                .fontWeight(.bold)
                                .foregroundColor(communityManager.convertStringToColor(color: dream.authorColor!))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.trailing, 10)
                                .padding(.bottom, 20)
                        }.simultaneousGesture(TapGesture().onEnded {
                            communityManager.retrieverUserFromFirestore(userId: dream.authorId!)
                        })
                        
                        
                        // Dream details text
                        HStack {
                            
                            if let text = communityManager.focusedTextFormatted {
                                Text(AttributedString(text))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                                    .padding(.bottom, 20)
                            } else {
                                Image("sleep_face")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .opacity(0.6)
                                    .padding(.top, 60)
                            }
                        }
                        
                        // Tags
                        HStack() {
                            if let tags = dream.tags {
                                if !tags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(tags, id: \.self) { tag in
                                                TagView(index: 0, text: tag["text"] ?? "Dream", icon: tag["icon"] ?? "sun.max", color: communityManager.convertStringToColor(color: tag["color"] ?? "red"), isEditable: false)
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        
                        
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color.black, lineWidth: 1)
                                .frame(minWidth: 10, maxWidth: 110, minHeight: 35)
                                .overlay {
                                    HStack {
                                        Button(action: {
                                            if let user = userManager.user {
                                                // Rate limiting check
                                                if let rateLimit = userManager.processFirestoreWrite() {
                                                    print(rateLimit)
                                                } else {
                                                    communityManager.processKarmaVote(userId: user.id!, dream: communityManager.focusedDream!, isUpvote: true)
                                                }
                                            }
                                        }) {
                                            if !communityManager.localKarmaVotes.keys.contains(dream.id!) {
                                                Image(systemName: "arrowshape.up")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(.black)
                                            } else if communityManager.localKarmaVotes[dream.id!] == true {
                                                Image(systemName: "arrowshape.up")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(.orange)
                                            } else {
                                                Image(systemName: "arrowshape.up")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        
                                        
                                        // Define different colors for the text based on the local votes
                                        if !communityManager.localKarmaVotes.keys.contains(dream.id!) {
                                            Text("\(dream.karma!)")
                                                .foregroundStyle(.black)
                                        } else if communityManager.localKarmaVotes[dream.id!] == true {
                                            Text("\(dream.karma! + 1)")
                                                .foregroundStyle(.orange)
                                        } else {
                                            Text("\(dream.karma! - 1)")
                                                .foregroundStyle(.blue)
                                        }
                                        
                                        
                                        Divider()
                                            .foregroundColor(.black)
                                        
                                        Button(action: {
                                            if let user = userManager.user {
                                                // Rate limiting checl
                                                if let rateLimit = userManager.processFirestoreWrite() {
                                                    print(rateLimit)
                                                } else {
                                                    communityManager.processKarmaVote(userId: user.id!, dream: communityManager.focusedDream!, isUpvote: false)
                                                }
                                            }
                                        }) {
                                            
                                            if !communityManager.localKarmaVotes.keys.contains(dream.id!) {
                                                Image(systemName: "arrowshape.down")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(.black)
                                            } else if communityManager.localKarmaVotes[dream.id!] == true {
                                                Image(systemName: "arrowshape.down")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(.black)
                                            } else {
                                                Image(systemName: "arrowshape.down")
                                                    .resizable()
                                                    .frame(width: 18, height: 18)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            Spacer()
                        }
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        
                        
                        // Dream Image
                        HStack {
                            if let image = communityManager.retrievedImages[dream.id!] {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 300, height: 240)
                                    .cornerRadius(25)
                            } else {
                                //                    Image(homeManager.randomImage())
                                //                        .resizable()
                                //                        .frame(width: 100, height: 60)
                                //                        .clipShape(Circle())
                            }
                            
                        }
                        .padding(.bottom, 10)
                        
                        Text("Analysis")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                        
                        if let textAnalysis = dream.AITextAnalysis {
                            Text(textAnalysis)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                        } else {
//                            Text("Sorry couldn't find the analysis")
//                                .font(.subheadline)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 20)
//                                .padding(.trailing, 20)
//                                .padding(.bottom, 20)
                        }
                    }
                } else {
                    Image("sleep_face")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .opacity(0.6)
                        .padding(.top, 60)
                    
                    
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .stroke(Color.black, lineWidth: 1)
                        .frame(minWidth: 10, maxWidth: 125, minHeight: 40)
                        .overlay {
                            HStack {
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "arrowshape.up")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.black)
                                }
                                
                                Text("34")
                                
                                Divider()
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "arrowshape.down")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                }
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    SingleCommunityDream()
        .environmentObject(CommunityManager())
}
