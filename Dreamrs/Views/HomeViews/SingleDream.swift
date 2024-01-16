//
//  SingleDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct SingleDream: View {
    
    @EnvironmentObject var homeManager: HomeManager
    @EnvironmentObject var userManager: UserManager
    
//    @State var isDreamAlreadyPinned: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                if let dream = homeManager.focusedDream {
                    VStack {
                        // Date
                        HStack {
                            Text(dream.date!)
                                .opacity(0.7)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                            
                            
                            
                            // Display pin dream button if the dream is not already pinned
                            if !homeManager.isFocusedDreamPinned {
                                Button(action: {
                                    homeManager.isConfirmPinnedDreamPopupShowing = true
                                }) {
                                    Image(systemName: "plus.app")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.black)
                                }.popover(isPresented: $homeManager.isConfirmPinnedDreamPopupShowing) {
                                    PinDreamView()
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Dream Title
                        HStack {
                            Text(dream.title!)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.bottom, 20)
                        }
                        
                        // Dream details text
                        HStack {
                            
                            if let text = homeManager.focusedTextFormatted {
                                Text(AttributedString(text))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20)
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
                                                TagView(index: 0, text: tag["text"] ?? "Dream", icon: tag["icon"] ?? "sun.max", color: homeManager.convertStringToColor(color: tag["color"] ?? "red"), isEditable: false)
                                            }
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
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            homeManager.isFocusedDreamPinned = false
            if let map = userManager.user?.pinnedDreams {
                if let dreamId = homeManager.focusedDream!.id {
                    // Constant loop, only 3 max dreamMaps
                    for dreamMap in map {
                        if dreamMap["dreamId"] == dreamId {
                            homeManager.isFocusedDreamPinned = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SingleDream()
        .environmentObject(HomeManager())
        .environmentObject(UserManager())
}
