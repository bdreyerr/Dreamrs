//
//  CommunityMainView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct CommunityMainView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Logo
                    HStack {
                        Image("home_logo")
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        Text("D R E A M B O A R D")
                            .font(.system(size: 14))
                            .padding(.trailing, 20)
//                            .padding(.bottom, 15)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom, 20)
                    
                    // Following vs. For You
                    HStack {
                        Button(action: {
                            
                        }) {
                            Text("Following")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
//                                .bold()
                                .foregroundColor(.black)
                        }
                        
                        Button(action: {
                            
                        }) {
                            Text("For You")
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                                .bold()
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack {
                        ScrollView {
                            NavigationLink(destination: SingleDream()) {
                                HStack {
                                    VStack {
                                        Image(systemName: "arrowtriangle.up")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                            
                                        
                                        Text("112")
                                            .foregroundColor(.black)
                                        
                                        Image(systemName: "arrowtriangle.down")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.trailing, 5)
                                    VStack {
                                        Text("Swimming with mermaids")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 16, design: .serif))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("@flowerlucy")
                                            .foregroundStyle(.purple)
                                            .bold()
                                            .font(.system(size: 16, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 1)
                                        
                                            Text("Oct 9th, 2023")
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
                            
                            NavigationLink(destination: SingleDream()) {
                                HStack {
                                    VStack {
                                        Image(systemName: "arrowtriangle.up")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                            
                                        
                                        Text("78")
                                            .foregroundColor(.black)
                                        
                                        Image(systemName: "arrowtriangle.down")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.trailing, 5)
                                    VStack {
                                        Text("Meeting the president, getting a kiss.")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 16, design: .serif))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("@luckyluke")
                                            .foregroundStyle(.red)
                                            .bold()
                                            .font(.system(size: 16, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 1)
                                        
                                            Text("Aug 4th, 2023")
                                                .foregroundStyle(.gray)
                                                .font(.system(size: 14, design: .serif))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Image("dream4")
                                        .resizable()
                                        .frame(width: 100, height: 60)
                                        .clipShape(Circle())
                                }
                            }
                            
                            NavigationLink(destination: SingleDream()) {
                                HStack {
                                    VStack {
                                        Image(systemName: "arrowtriangle.up")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                            
                                        
                                        Text("45")
                                            .foregroundColor(.black)
                                        
                                        Image(systemName: "arrowtriangle.down")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.trailing, 5)
                                    VStack {
                                        Text("Stealing the declaration of independence")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 16, design: .serif))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("@bendben")
                                            .foregroundStyle(.blue)
                                            .bold()
                                            .font(.system(size: 16, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 1)
                                        
                                            Text("Jan 14th, 2023")
                                                .foregroundStyle(.gray)
                                                .font(.system(size: 14, design: .serif))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Image("dream5")
                                        .resizable()
                                        .frame(width: 100, height: 60)
                                        .clipShape(Circle())
                                }
                            }
                            
                            NavigationLink(destination: SingleDream()) {
                                HStack {
                                    VStack {
                                        Image(systemName: "arrowtriangle.up")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                            
                                        
                                        Text("22")
                                            .foregroundColor(.black)
                                        
                                        Image(systemName: "arrowtriangle.down")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.trailing, 5)
                                    VStack {
                                        Text("Mental breakdown on an airplane")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 16, design: .serif))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("@wilsonlewis")
                                            .foregroundStyle(.green)
                                            .bold()
                                            .font(.system(size: 16, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 1)
                                        
                                            Text("Mar 30th, 2023")
                                                .foregroundStyle(.gray)
                                                .font(.system(size: 14, design: .serif))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Image("dream6")
                                        .resizable()
                                        .frame(width: 100, height: 60)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.leading, 20)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

struct CommunityMainView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityMainView()
    }
}
