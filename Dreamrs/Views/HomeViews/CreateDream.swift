//
//  CreateDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct CreateDream: View {
    
    @State var dreamText: String = ""
    
    // Text formatting
    @State var isBoldSelected: Bool = false
    @State var isItalicSelected: Bool = false
    @State var isUnderlineSelected: Bool = false
    
    @State var isKeyboardShowing: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("D R E A M B O A R D")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 15)
                    .font(.subheadline)
                    .bold()
                
                
                Text("November 20th, 2023")
                    .font(.system(size: 18, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 15)
                    .font(.subheadline)
//                    .bold()
                
                ScrollView {
                    // If keyboard is not showing, show a text field with a longer line limit
                    
                    TextField("Last night I....", text: $dreamText, axis: .vertical)
                        .foregroundColor(.black)
                        .font(.system(size: 14, design: .serif))
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .lineLimit( isKeyboardShowing ? 5...10 : 20...22)
                        .onTapGesture {
                            if !isKeyboardShowing {
                                isKeyboardShowing = true
                            }
                        }
                    
//                    if !isKeyboardShowing {
//                        TextField("Last night I....", text: $dreamText, axis: .vertical)
//                            .foregroundColor(.black)
//                            .padding(10)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .padding(.leading, 20)
//                            .padding(.trailing, 20)
//                            .lineLimit(20...22)
//                            .onTapGesture {
//                                isKeyboardShowing = true
//                                print(isKeyboardShowing)
//                            }
//                    } else {
//                        TextField("Last night I....", text: $dreamText, axis: .vertical)
//                            .foregroundColor(.black)
//                            .padding(10)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .padding(.leading, 20)
//                            .padding(.trailing, 20)
//                            .lineLimit(5...10)
//                    }
//                    
                    
//                    Spacer()
                }
                .scrollDismissesKeyboard(.immediately)
//                .animation(.easeInOut(duration: 0.6))
                
                HStack {
                    Button(action: {
                        print("Bold button clicked!")
                        isBoldSelected = !isBoldSelected
                    }) {
                        if !isBoldSelected {
                            // Bold not selected
                            Image(systemName: "bold")
                                .resizable()
                                .frame(width: 14, height: 18)
                                .font(.title)
                                .foregroundColor(.black)
                                .padding(20)
                                .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.834))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        } else {
                            // Bold selected
                            Image(systemName: "bold")
                                .resizable()
                                .frame(width: 18, height: 23)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(hue: 0.123, saturation: 0.842, brightness: 0.93))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        }
                    }
                    .padding(.trailing, 20)
                    
                    Button(action: {
                        print("Italics button clicked!")
                        isItalicSelected = !isItalicSelected
                    }) {
                        if !isItalicSelected {
                            Image(systemName: "italic")
                                .resizable()
                                .frame(width: 14, height: 18)
                                .font(.title)
                                .foregroundColor(.black)
                                .padding(20)
                                .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.834))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        } else {
                            Image(systemName: "italic")
                                .resizable()
                                .frame(width: 18, height: 23)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(hue: 0.123, saturation: 0.842, brightness: 0.93))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        }
                    }
                    .padding(.trailing, 20)
                    
                    Button(action: {
                        print("Underline button clicked!")
                        isUnderlineSelected = !isUnderlineSelected
                    }) {
                        if !isUnderlineSelected {
                            Image(systemName: "underline")
                                .resizable()
                                .frame(width: 14, height: 18)
                                .font(.title)
                                .foregroundColor(.black)
                                .padding(20)
                                .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.834))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        } else {
                            Image(systemName: "underline")
                                .resizable()
                                .frame(width: 18, height: 23)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(hue: 0.123, saturation: 0.842, brightness: 0.93))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        }
                    }
                    .padding(.trailing, 20)
                    
                    
                    Button(action: {
                        print("user finished their dream")
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
                }
                .padding(.bottom, 30)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                // Code to be executed when the keyboard disappears
                isKeyboardShowing = false
            }
        }
    }
}

struct CreateDream_Previews: PreviewProvider {
    static var previews: some View {
        CreateDream()
    }
}
