//
//  PinDreamView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/10/24.
//

import SwiftUI

struct PinDreamView: View {
    
    @EnvironmentObject var homeManager: HomeManager
    @EnvironmentObject var userManager: UserManager
    
    @State var confirmPin: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    
                    
                    // Pinned Dreams
                    VStack {
                        Text("Currently Pinned Dreams")
                            .font(.system(size: 18))
                            .fontDesign(.serif)
                            .bold()
                        
                        ForEach(userManager.pinnedDreams) { dream in
                            AlreadyPinnedDream(dream: dream, index: userManager.pinnedDreams.firstIndex(of: dream)!)
                        }
                        
                        if userManager.pinnedDreams.count != 3 {
                            Button(action: {
                                self.confirmPin = true
                            }) {
                                Image(systemName: "plus.app")
                                    .resizable()
                                    .frame(width: 25, height:  25)
                                    .foregroundStyle(Color.black)
                            }
                            .alert("Pin Dream?", isPresented: self.$confirmPin) {
                                Button("Confirm") {
                                    // Rate Limiting check
                                    if let _ = userManager.user {
                                        if let rateLimit = userManager.processFirestoreWrite() {
                                            print(rateLimit)
                                        } else {
                                            userManager.pinDream(dreamId: homeManager.focusedDream!.id!, date: homeManager.focusedDream!.date!)
                                            print("Action confirmed, adding dream!")
                                            homeManager.isConfirmPinnedDreamPopupShowing = false
                                            homeManager.isFocusedDreamPinned = true
                                        }
                                    }
                                }
                                Button("Cancel", role: .cancel) { }
                            }
                        }
                        
                        
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
                    
                    
//                    Text("Are you sure you want to pin this dream?")
//                    Button(action: {
//                        if let user = userManager.user {
//                            if let dream = homeManager.focusedDream {
//                                if user.pinnedDreams!.count < 3 {
//                                    userManager.pinDream(dreamId: dream.id!, date: dream.date!, indexOfReplacedDream: -1)
//                                } else {
//                                    print("User already has three dreams pinned")
//                                }
//                                homeManager.isConfirmPinnedDreamPopupShowing = false
//                            }
//                        }
//                    }) {
//                        Text("Yes")
//                    }
//                    Button(action: {
//                        homeManager.isConfirmPinnedDreamPopupShowing = false
//                    }) {
//                        Text("No")
//                    }
                }
            }
        }
        .onAppear {
            if let _ = userManager.user {
                userManager.loadPinnedDreams(isRefresh: false)
            }
        }
    }
}

#Preview {
    PinDreamView()
        .environmentObject(HomeManager())
        .environmentObject(UserManager())
}

struct AlreadyPinnedDream : View {
    var dream: Dream
    var index: Int
    
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var homeManager: HomeManager
    
    @State var confirmPin: Bool = false
    
    var body: some View {
        Button(action: {
            self.confirmPin = true
        }) {
            HStack {
                HStack {
                    VStack {
                        Text(dream.title!)
                            .foregroundStyle(.black)
                            .font(.system(size: 14, design: .serif))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(dream.date!)
                                .foregroundStyle(.gray)
                                .font(.system(size: 14, design: .serif))
                                .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Image("dream3")
                        .resizable()
                        .frame(width: 100, height: 60)
                        .clipShape(Circle())
                }
                
            }
            Image(systemName: "xmark.bin.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.red)
        }
        .alert("Delete Pinned Dream \(index + 1)?", isPresented: $confirmPin) {
            Button("Confirm") {
                userManager.removePinnedDream(indexOfRemovedDream: self.index)
                print("Replacing the pinned dream!")
            }
            Button("Cancel", role: .cancel) { }
        }
        
    }
}
