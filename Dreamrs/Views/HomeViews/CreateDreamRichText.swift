//
//  TestingRichTestKit.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/7/23.
//

import SwiftUI
import RichTextKit

struct CreateDreamRichText: View {
    
    @StateObject var createDreamManager = CreateDreamManager()
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var homeManager: HomeManager
    
    var body: some View {
        ZStack {
            VStack {
                Text("D R E A M B O A R D")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 15)
                    .font(.subheadline)
                    .bold()
                
                
                // TODO: show the current date formatted to day
                Text(createDreamManager.date ?? "Today")
                    .font(.system(size: 18, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 15)
                    .font(.subheadline)
                //                    .bold()
                
                TextField("Dream title", text: $createDreamManager.title, axis: .horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 20, design: .serif))
                    .padding(.bottom, 15)
                    .padding(.leading, 25)
                    .font(.subheadline)
                
                
                ZStack {
                    RichTextEditor(text: $createDreamManager.text, context: createDreamManager.context) {
                        $0.textContentInset = CGSize(width: 10, height: 20)
                    }
                    .background(.white)
                    .focusedValue(\.richTextContext, createDreamManager.context)
                    .cornerRadius(20)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .overlay {
                        
                    }
                        
//                    if createDreamManager.text.isEqual(to: NSAttributedString(string: "")) && !createDreamManager.context.isEditingText {
//                        Text("Last Night I...")
//                            .font(.system(size: 15, design: .serif))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 25)
//                            .foregroundColor(.gray)
//                            
//                    }
                    
                    
                }
                
                
                
                Button(action: {

                    createDreamManager.isReadyToSubmitPopupShowing = true
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color(hue: 0.352, saturation: 0.69, brightness: 0.81))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                }
                .padding(.bottom, 10)
                .popover(isPresented: $createDreamManager.isReadyToSubmitPopupShowing, content: {
                    VStack {
                        let atrbText = AttributedString(createDreamManager.text)
                        Text(createDreamManager.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 20, design: .serif))
                            .padding(.top, 40)
                            .padding(.leading, 20)
                            .font(.subheadline)
                        ScrollView {
                            Text(atrbText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        
                        
                        // AI choices
                        HStack {
                            Text("Visualize this dream with AI?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16, design: .serif))
                            
                            Button(action: {
                                createDreamManager.shouldVisualizeDream.toggle()
                            }) {
                                if !createDreamManager.shouldVisualizeDream {
                                    Image(systemName: "square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "checkmark.square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 10)
                        
                        HStack {
                            Text("Analyze this dream with AI?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16, design: .serif))
                            
                            Button(action: {
                                createDreamManager.shouldAnalyzeDream.toggle()
                            }) {
                                if !createDreamManager.shouldAnalyzeDream {
                                    Image(systemName: "square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "checkmark.square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 10)
                        
                        // Community Sharing
                        HStack {
                            Text("Share this dream with your followers?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16, design: .serif))
                            
                            
                            Button(action: {
                                createDreamManager.shareWithFriends.toggle()
                            }) {
                                if !createDreamManager.shareWithFriends {
                                    Image(systemName: "square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "checkmark.square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.trailing, 20)
                            
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 10)
                        
                        HStack {
                            Text("Share this dream with the community?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16, design: .serif))
                            
                            Button(action: {
                                createDreamManager.shareWithCommunity.toggle()
                            }) {
                                if !createDreamManager.shareWithCommunity {
                                    Image(systemName: "square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "checkmark.square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                        
                        
                        Button(action: {
                            // Grab the userId and userHandle from userManager
                            if let user = userManager.user {
                                if let dream = createDreamManager.submitDream(userId: user.id!, userHandle: user.handle!) {
                                    homeManager.displayDream(dream: dream)
                                    // dismiss the create popup
                                    homeManager.isCreateDreamPopupShowing = false
                                    
                                    // call the view published popup
                                    homeManager.isViewNewlyCreatedDreamPopupShowing = true
                                    homeManager.isNewDreamLoading = true
                                    homeManager.processNewDream(dream: dream, shouldVisualizeDream: createDreamManager.shouldVisualizeDream, shouldAnalyzeDream: createDreamManager.shouldAnalyzeDream)
                                } else {
                                    homeManager.isCreateDreamPopupShowing = false
//                                    
//                                    // call the view published popup
//                                    homeManager.isViewNewlyCreatedDreamPopupShowing = true
//                                    homeManager.isNewDreamLoading = false
//                                    homeManager.isErrorLoadingNewDream = true
                                }
                                
                                
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(hue: 0.352, saturation: 0.69, brightness: 0.81))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        }
                    }
                })
                
                RichTextKeyboardToolbar(
                    context: createDreamManager.context,
                    leadingButtons: {},
                    trailingButtons: {}
                )
            }
            .padding(.top, 40)
        }
        .environmentObject(createDreamManager)
        .onDisappear {
            print("leaving")
            createDreamManager.context.isEditingText = false
        }
    }
}

#Preview {
    CreateDreamRichText()
}
