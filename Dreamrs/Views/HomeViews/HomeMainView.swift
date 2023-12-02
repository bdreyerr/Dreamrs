//
//  HomeMainView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct HomeMainView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("home_bg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // Welcome Name
                    HStack {
                        VStack {
                            Text("Good Morning!")
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Ben")
                                .font(.system(size: 22))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.bold)
                        }
                        .padding(.leading, 25)
                        
                        Text("Dreamr")
                            .font(.system(size: 16))
                            .padding(.trailing, 20)
                            .padding(.bottom, 15)
                    }
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 25)
                    
                    // Simple Cal
                    SimpleCalView()
                    
                    
                    ScrollView {
                        NavigationLink(destination: SingleDream()) {
                            RoundedRectangle(cornerRadius: 25)
                                .overlay {
                                    HStack {
                                        VStack {
                                            Text("Stary Night")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .fontWeight(.medium)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("November 6th, 2023")
                                                .foregroundColor(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.light)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.leading, 20)
                                        
                                        Image(systemName: "text.book.closed")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 30, height: 30)
                                            .padding(.trailing, 20)
                                        
                                    }
                                    
                                }
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.945))
                                .frame(width: 360, height: 100)
                        }
                        .padding(.bottom, 5)
                        
                        NavigationLink(destination: SingleDream()) {
                            RoundedRectangle(cornerRadius: 25)
                                .overlay {
                                    HStack {
                                        VStack {
                                            Text("Late for class")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .fontWeight(.medium)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("November 4th, 2023")
                                                .foregroundColor(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.light)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.leading, 20)
                                        
                                        Image(systemName: "graduationcap")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 30, height: 30)
                                            .padding(.trailing, 20)
                                        
                                    }
                                    
                                }
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.945))
                                .frame(width: 360, height: 100)
                        }
                        .padding(.bottom, 5)
                        
                        NavigationLink(destination: SingleDream()) {
                            RoundedRectangle(cornerRadius: 25)
                                .overlay {
                                    HStack {
                                        VStack {
                                            Text("Flying through New York")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .fontWeight(.medium)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("November 1st, 2023")
                                                .foregroundColor(.black)
                                                .font(.system(size: 14))
                                                .fontWeight(.light)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.leading, 20)
                                        
                                        Image(systemName: "cloud")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 34, height: 28)
                                            .padding(.trailing, 20)
                                        
                                    }
                                    
                                }
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.945))
                                .frame(width: 360, height: 100)
                        }
                        .padding(.bottom, 5)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Circle()
                            //                            .strokeBorder(.red, lineWidth: 20)
                                .foregroundColor(.red)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "highlighter")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                }
                            
                                .padding(.bottom, 20)
                                .padding(.trailing, 20)
                                .shadow(color: Color(hue: 1.0, saturation: 0.522, brightness: 0.546), radius: 5, x: 10, y: 10)
                                .opacity(1.0)
                        }
                    }
                    
                }
                .padding(.top, 40)
                
            }
        }
        
    }
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}


struct SimpleCalView: View {
    var body: some View {
        // Simple Calendar
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Fri")
                                    .foregroundColor(.black)
                                Text("7")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Sat")
                                    .foregroundColor(.black)
                                Text("8")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
//                        .strokeBorder(.gray, lineWidth: 2)
//                        .background(RoundedRectangle(cornerRadius: 15).fill(.white))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 80)
                        .overlay {
                            VStack {
                                Text("Sun")
                                    .foregroundColor(.black)
                                Text("9")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Mon")
                                    .foregroundColor(.black)
                                Text("10")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Tue")
                                    .foregroundColor(.black)
                                Text("11")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Wed")
                                    .foregroundColor(.black)
                                Text("12")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Thu")
                                    .foregroundColor(.black)
                                Text("12")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
                Button(action: {

                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.gray, lineWidth: 1)
                        .background(Circle().fill(.clear))
                        .frame(width: 50, height: 70)
                        .overlay {
                            VStack {
                                Text("Fri")
                                    .foregroundColor(.black)
                                Text("13")
                                    .foregroundColor(.black)
                            }
                        }
                }
                .padding(.trailing, 5)
            }
        }
        .padding(.bottom, 20)
    }
}
