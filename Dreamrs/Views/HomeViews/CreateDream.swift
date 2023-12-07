//
//  CreateDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct CreateDream: View {
    
    @StateObject var createDreamManager = CreateDreamManager()
    
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
                
                
                // TODO: show the current date formatted to day
                Text("November 20th, 2023")
                    .font(.system(size: 18, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 15)
                    .font(.subheadline)
//                    .bold()
                
                ScrollView {
                // If keyboard is not showing, show a text field with a longer line limit
                    
                Text("**will this be bold?**")
                Text("_will this be italic?_")
                Text("will this be underline?")
                    
                    
                ForEach(createDreamManager.totalText) { textDict in
                    let text = textDict.text
                    let format = textDict.format
                    
                    
                    switch format {
                    case [false, false, false]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                    case [true, false, false]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .bold()
                    case [false, true, false]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .italic()
                    case [false, false, true]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .underline()
                    case [true, true, false]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .bold()
                            .italic()
                    case [true, false, true]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .bold()
                            .underline()
                    case [false, true, true]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .italic()
                            .underline()
                    case [true, true, true]:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                            .bold()
                            .italic()
                            .underline()
                    default:
                        Text(text!)
                            .foregroundColor(.black)
                            .font(.system(size: 14, design: .serif))
                    }
                }
                    
                    switch createDreamManager.currentFormat {
                    case [false, false, false]: 
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
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
                    case [true, false, false]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .bold()
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
                    case [false, true, false]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .italic()
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
                    case [false, false, true]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .underline()
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
                    case [true, true, false]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .bold()
                            .italic()
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
                    case [true, false, true]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .bold()
                            .underline()
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
                    case [false, true, true]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .italic()
                            .underline()
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
                    case [true, true, true]:
                        TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
                            .bold()
                            .italic()
                            .underline()
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
                    default: Text("argabarga")
                    }
                    
//                    TextField("Last night I....", text: $createDreamManager.currentText, axis: .vertical)
//                        .foregroundColor(.black)
//                        .font(.system(size: 14, design: .serif))
//                        .padding(10)
//                        .background(Color.white)
//                        .cornerRadius(20)
//                        .padding(.leading, 20)
//                        .padding(.trailing, 20)
//                        .lineLimit( isKeyboardShowing ? 5...10 : 20...22)
//                        .onTapGesture {
//                            if !isKeyboardShowing {
//                                isKeyboardShowing = true
//                            }
//                        }
                    
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
                        createDreamManager.toggleBold()
                    }) {
                        if !createDreamManager.currentFormat[0] {
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
                    .padding(.trailing, 15)
                    
                    Button(action: {
                        print("Italics button clicked!")
                        createDreamManager.toggleItalic()
                    }) {
                        if !createDreamManager.currentFormat[1] {
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
                    .padding(.trailing, 15)
                    
                    Button(action: {
                        print("Underline button clicked!")
                        createDreamManager.toggleUnderline()
                    }) {
                        if !createDreamManager.currentFormat[2] {
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
                    .padding(.trailing, 15)
                    
                    Button(action: {
                        print("User wanted to add color to their text")
                    }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .orange, .yellow, .green, .blue, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    }
                    .padding(.trailing, 15)
                    
                    
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
        .environmentObject(createDreamManager)
    }
}

struct CreateDream_Previews: PreviewProvider {
    static var previews: some View {
        CreateDream()
    }
}
