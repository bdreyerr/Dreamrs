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
            Color(UIColor.systemGray4).ignoresSafeArea()
            
            
            ScrollView {
                VStack {
                    // Title and Settings
                    Group {
                        HStack {
                            Button(action: {
                                
                            }){
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .opacity(0.7)
                                    .padding(.trailing, 20)
                            }
                            
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Date
                    HStack {
                        Text("Sunday, November 7th, 2023")
                            .opacity(0.7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                    }
                    
                    // Dream Title
                    HStack {
                        Text("Lorem ipsum fallum if ep genum esus")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // Dream details text
                    HStack {
                        Text("I was surrounded by stars and nebulae, and I felt a sense of awe and wonder. I flew through a black hole and emerged into a new universe. This universe was different from our own in many ways. The laws of physics were different, and the landscape was alien and beautiful. \n\nI met strange and wonderful creatures, and I learned about their culture and way of life. It was an amazing experience, and I woke up feeling inspired and refreshed.\n\nI think this dream is a reflection of my own curiosity and desire to explore. I am always interested in learning new things and seeing the world from new perspectives. The dream also represents my belief in the infinite possibilities of the universe. I think that there are things out there that we can't even imagine, and I am excited to see what the future holds. ")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // Tags
                    HStack() {
                        Label("Space", systemImage: "sun.max")
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.blue.opacity(0.75), in: Capsule())
                        Label("Exploration", systemImage: "sun.max")
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.purple.opacity(0.75), in: Capsule())
                        Label("Visual", systemImage: "sun.max")
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
                        Image("single_dream_image")
                            .resizable()
                            .frame(width: 300, height: 180)
                            .cornerRadius(25)
                            
                    }
                    
                    Spacer()
                    
                }
                .padding(.top, 40)
            }
        }
    }
}

struct SingleDream_Previews: PreviewProvider {
    static var previews: some View {
        SingleDream()
    }
}
