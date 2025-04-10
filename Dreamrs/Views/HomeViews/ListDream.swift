//
//  ListDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 4/10/25.
//

import SwiftUI

struct ListDream: View {
    
    @EnvironmentObject var homeManager: HomeManager

    var dream: Dream
    var title: String
    var date: String
    var dayOfWeek: String
    
    var body: some View {
        NavigationLink(destination: SingleDream()) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    
                    if dream.hasImage == false || dream.hasImage == nil {
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 140)
                            
                            Image("sleep_face")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                                .opacity(0.4)
                        }
                    } else {
                        if let image = homeManager.retrievedImages[dream.id!] {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 140)
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 140)
                                    .clipped()
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 140)
                            }
                        }
                    }
                    
                    // Adult content indicator
                    if let hasAdultContent = dream.hasAdultContent, hasAdultContent {
                        Text("18+")
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(12)
                            .padding(6)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title row
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                    
                    // Date
                    Text(date)
                        .font(.system(size: 11, design: .serif))
                        .foregroundStyle(.gray)
                    
                    // Tags - only show if there's space
                    if let tags = dream.tags, !tags.isEmpty {
                        HStack {
                            ForEach(tags.prefix(2), id: \.self) { tag in
                                TagView(index: 0, text: tag["text"] ?? "Dream", icon: tag["icon"] ?? "sun.max", color: homeManager.convertStringToColor(color: tag["color"] ?? "red"), isEditable: false, customSize: 9)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .frame(height: 220)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .simultaneousGesture(TapGesture().onEnded {
            homeManager.displayDream(dream: self.dream)
        })
    }
}

struct TitleTextView: View {
    let dayOfWeek: String
    
    var body: some View {
        switch(dayOfWeek) {
        case "Monday":
            Text(dayOfWeek)
                .foregroundStyle(.purple)
                
        case "Tuesday":
            Text(dayOfWeek)
                .foregroundStyle(.blue)
                
        case "Wednesday":
            Text(dayOfWeek)
                .foregroundStyle(.green)
                
        case "Thursday":
            Text(dayOfWeek)
                .foregroundStyle(.red)

        case "Friday":
            Text(dayOfWeek)
                .foregroundStyle(.mint)
                
        case "Saturday":
            Text(dayOfWeek)
                .foregroundStyle(.orange)
                
        case "Sunday":
            Text(dayOfWeek)
                .foregroundStyle(.indigo)
                
        default:
            Text(dayOfWeek)
                .foregroundStyle(.black)
        }
    }
}
