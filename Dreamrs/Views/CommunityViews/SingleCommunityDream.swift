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
                            Image("dad_dog")
                                .resizable()
                                .frame(width: 300, height: 180)
                                .cornerRadius(25)
                            
                        }
                        .padding(.bottom, 10)
                        
                        Text("Analysis")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                        
                        Text("This dream seems to encompass several themes and elements that may reflect the dreamer's subconscious concerns, aspirations, and experiences:\n\n1. Family Dynamics and Support: The dream prominently features the dreamer's Dad, suggesting a significant role or influence. The shared activity of the drive and the visit to the puppy adoption center may signify a connection or bonding experience with the father.\n\n2. Transition and Movement: The car moving backward after being parked in neutral could symbolize a sense of regression or unexpected setbacks. This might mirror feelings of losing control or facing challenges in moving forward.\n\n3. Desire for Companionship and Responsibility: The visit to the puppy adoption center, initiated by the Dad, reflects a desire for companionship or the assumption of responsibility. This could signify a longing for connection, nurturing, or the introduction of new elements in the dreamer's life.\n\n4. Educational and Future Planning: The dreamer's focus on looking for grad schools, particularly in California, indicates a preoccupation with future plans and educational pursuits. This may suggest a conscious or subconscious consideration of career paths, personal growth, or a desire for a change in surroundings.\n\n5. Selective Memory and Foggy Details: The dreamer acknowledges that some details are foggy or unclear, suggesting the impermanence of dream memories. This could symbolize uncertainty or a lack of clarity in certain aspects of the dreamer's waking life or future plans.\n\n6. Potential Stress or Anxiety: The dreamer mentioning that there was something happening before in the dream that they can't recall may indicate a sense of stress or anxiety. The inability to remember certain details might point to underlying concerns or unresolved issues.\n\nIn summary, this dream weaves together elements of family, transition, desires for companionship and responsibility, educational aspirations, and potential stress or uncertainty. The dreamer's subconscious mind may be processing a mix of emotions and thoughts related to various aspects of their life.")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
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
