//
//  SingleDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct SingleDream: View {
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // Date
                    HStack {
                        Text("Sunday, November 7th, 2023")
                            .opacity(0.7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                    }
                    .padding(.top, 10)
                    
                    // Dream Title
                    HStack {
                        Text("Driving with Dad, looking for puppies")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // Dream details text
                    HStack {
                        Text("Had an interesting dream last night, some of it is foggy but it went basically like this. I remember being on a drive with my Dad and we had parked at some sort of grocery store or strip mall thing. The car started to move backwards after we parked it because we left it in neutral.\n\nMy dad also then took me to puppy adoption center because he thought that I might want a Dog. I think I was like looking for grad schools to apply to and that’s why we were on the trip. I remember someone asking me about what my plans were and I told them that I was looking at grad schools only really in California. I think there was something going on before at the earlier part of my dream but I can’t really remember.")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // Tags
                    HStack() {
                        Label("Family", systemImage: "sun.max")
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.blue.opacity(0.75), in: Capsule())
                        Label("Transitions", systemImage: "sun.max")
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.purple.opacity(0.75), in: Capsule())
                        Label("Future", systemImage: "sun.max")
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.red.opacity(0.75), in: Capsule())
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
                    
                    Spacer()
                    
                }
                .padding(.top, 10)
            }
            .padding(.bottom, 20)
        }
    }
}

struct SingleDream_Previews: PreviewProvider {
    static var previews: some View {
        SingleDream()
    }
}
