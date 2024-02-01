//
//  HomeView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/19/23.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @StateObject var homeManager = HomeManager()
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Logo
                    HStack {
                        Image("home_logo")
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        Text("D R E A M R S")
                            .font(.system(size: 14))
                            .padding(.trailing, 20)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom, 20)
                    
                    // Month Selector
                    HStack {
                        Menu {
                            Picker(selection: $homeManager.selectedMonth) {
                                ForEach(homeManager.months, id: \.self) { value in
                                    Text(value)
                                        .tag(value)
                                        .font(.system(size: 16, design: .serif))
                                        .accentColor(.black)
                                        .bold()
                                        
                                }
                            } label: {}
                            .accentColor(.black)
                            .padding(.leading, -12)
                            .font(.system(size: 16, design: .serif))
                            .onChange(of: homeManager.selectedMonth) { newValue in
                                if let user = userManager.user {
                                    homeManager.retrieveDreams(userId: user.id!)
                                }
                                
                            }
                        } label: {
                            HStack {
                                Text(homeManager.selectedMonth)
                                    .font(.system(size: 16, design: .serif))
                                    .accentColor(.black)
                                    .bold()
                                Image(systemName: "arrowtriangle.down.fill")
                                    .resizable()
                                    .frame(width: 12, height: 6)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 20)
//                    .padding(.bottom, 15)
                    
                    // Year Selector
                    HStack {
                        Menu {
                            Picker(selection: $homeManager.selectedYear) {
                                ForEach(homeManager.years, id: \.self) { value in
                                    Text(value)
                                        .tag(value)
                                        .font(.system(size: 16, design: .serif))
                                        .accentColor(.black)
                                        .bold()
                                        
                                }
                            } label: {}
                            .accentColor(.black)
                            .padding(.leading, -12)
                            .font(.system(size: 16, design: .serif))
                            .onChange(of: homeManager.selectedYear) { newValue in
                                if let user = userManager.user {
                                    homeManager.retrieveDreams(userId: user.id!)
                                }
                            }
                        } label: {
                            HStack {
                                Text(homeManager.selectedYear)
                                    .font(.system(size: 13, design: .serif))
                                    .accentColor(.black)
                                    .bold()
                                Image(systemName: "arrowtriangle.down.fill")
                                    .resizable()
                                    .frame(width: 12, height: 6)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 15)
                    
                    
                    
                    ScrollView(showsIndicators: false) {
//                        ListDream()
                        if homeManager.retrievedDreams.isEmpty {
                            Image("sleep_face")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .opacity(0.6)
                                .padding(.top, 60)
                        }
//                        Image(uiImage: homeManager.imageView.image!)
                        
                        ForEach(homeManager.retrievedDreams) { dream in
                            ListDream(dream: dream, title: dream.title!, date: dream.date!, dayOfWeek: dream.dayOfWeek!)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 25)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
//                        NavigationLink(destination: CreateDreamRichText()) {
////                            Image(systemName: "plus.square")
////                                .resizable()
////                                .frame(width: 25, height: 25)
////                                .font(.title)
////                                .foregroundColor(.white)
////                                .padding(20)
////                                .background(Color.red)
////                                .clipShape(Circle())
////                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
//                            
//                            Image("pencil")
//                                .resizable()
//                                .frame(width: 60, height: 60)
//                                .clipShape(Circle())
//                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
//                            
//                        }
                        Button(action: {
                            homeManager.isCreateDreamPopupShowing = true
                        }) {
                            Image("pencil")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
                        }
                        .sheet(isPresented: $homeManager.isCreateDreamPopupShowing) {
                            CreateDreamRichText()
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $homeManager.isViewNewlyCreatedDreamPopupShowing) {
                LoadingDreamView()
            }
        }
        .environmentObject(homeManager)
        .onAppear {
            if let user = Auth.auth().currentUser {
                homeManager.retrieveDreams(userId: user.uid)
            } else {
                print("no user yet")
            }
        }
        
    }
}

#Preview {
    HomeView()
}

struct ListDream: View {
    
    @EnvironmentObject var homeManager: HomeManager

    var dream: Dream
    var title: String
    var date: String
    var dayOfWeek: String
    
    var body: some View {
        NavigationLink(destination: SingleDream()) {
            HStack {
                VStack {
                    TitleTextView(dayOfWeek: dayOfWeek)
                        .bold()
                        .font(.system(size: 16, design: .serif))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 1)
                    
                    HStack {
                        Text(title)
                            .foregroundStyle(.black)
                            .font(.system(size: 18, design: .serif))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.bottom, 1)
                    
                    Text(date)
                        .foregroundStyle(.gray)
                        .font(.system(size: 14, design: .serif))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding(.leading, 20)
                .padding(.bottom, 10)
                
                if let image = homeManager.retrievedImages[dream.id!] {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 60)
                        .clipShape(Circle())
                } else {
//                    Image(homeManager.randomImage())
//                        .resizable()
//                        .frame(width: 100, height: 60)
//                        .clipShape(Circle())
                }
            }
            
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

struct LoadingDreamView : View {
    
    @EnvironmentObject var homeManager: HomeManager
    
    // Animation values for new dream
    @State var imageScale: CGFloat = 1.0
    @State var imageOpacity: Double = 1.0
    
    var body: some View {
        Group {
            if !homeManager.isErrorLoadingNewDream {
                Image("sleep_face")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, 60)
                    .scaleEffect(imageScale)
                    .opacity(imageOpacity)
                    .padding(.bottom, 40)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            imageScale = 1.1
                            imageOpacity = 0.6
                        }
                    }
                
                Text("Understanding your dream with artificial intelligence")
                    .font(.system(size: 15, design: .serif))
                    .italic()
                    .padding(.bottom, 20)
                
                Text("This may take a few moments")
                    .font(.system(size: 13, design: .serif))
                    .italic()
                
            } else {
                Text("Error loading your dream, please try again")
            }
        }
        .padding(.bottom, 100)
        .onAppear {
            self.imageScale = 1.0
            self.imageOpacity = 1.0
        }
        
        
    }
}
