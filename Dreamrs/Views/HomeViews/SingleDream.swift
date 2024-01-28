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
                            
                            
                            HStack {
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
                                    .padding(.trailing, 5)
                                }
                                
                                // Delete Dream
                                Button(action: {
                                    homeManager.isConfirmDeleteDreamAlertShowing = true
                                }) {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.black)
                                }
                                .alert("Do you want to delete this dream?", isPresented: $homeManager.isConfirmDeleteDreamAlertShowing) {
                                    Button("Confirm") {
                                        if let _ = userManager.user {
                                            homeManager.deleteDream()
                                            // check if the dream being deleted is part of the user's pinned dream, if so remove it 
                                            if let pinnedDreams = userManager.user?.pinnedDreams {
                                                var i = 0
                                                for pinnedDream in pinnedDreams {
                                                    if pinnedDream["dreamId"] == homeManager.focusedDream!.id {
                                                        userManager.removePinnedDream(indexOfRemovedDream: i)
                                                    }
                                                    i += 1
                                                }
                                            }
                                        }
                                    }
                                    Button("Cancel", role: .cancel) { }
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
                            // First check homeManager loaded images
                            if let image = homeManager.retrievedImages[dream.id!] {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 300, height: 240)
                                    .cornerRadius(25)
                            } else {
            //                    Image(homeManager.randomImage())
            //                        .resizable()
            //                        .frame(width: 100, height: 60)
            //                        .clipShape(Circle())
                                
                                // We  can then also check pinned dream images, if user is coming from profile
                                if let pinnedDreamImage = userManager.pinnedDreamImages[dream.id!] {
                                    Image(uiImage: pinnedDreamImage)
                                        .resizable()
                                        .frame(width: 300, height: 240)
                                        .cornerRadius(25)
                                }
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
