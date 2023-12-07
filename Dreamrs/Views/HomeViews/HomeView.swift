//
//  HomeView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/19/23.
//

import SwiftUI

struct HomeView: View {
    
    @State var animationVal: Double = 0.0
    
    @State var isSearchBarShowing: Bool = false
    @State var isCalPickerShowing: Bool = false
    
    
    @State var searchText: String = ""
    @State private var selectedMonth: String
    var months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "Novemeber", "December"]
    
    @State private var selectedDate: Date
    
    init(_ selectedDate: Date) {
        _selectedMonth = State(initialValue: months[10])
        _selectedDate = State(initialValue: selectedDate)
    }
    
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
                            .padding(.bottom, 15)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom, 20)
                    
                    
                    
                    // Date Picker & Search
                    HStack {
                        if !isSearchBarShowing {
                            Group {
                                
                                Menu {
                                    Picker(selection: $selectedMonth) {
                                        ForEach(months, id: \.self) { value in
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
                                } label: {
                                    HStack {
                                        Text(selectedMonth)
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
                                
//                                Menu {
//                                    DatePicker(selection: $selectedDate, in: ...Date.now, displayedComponents: .date) {
//                                        Text("Select a date")
//                                    }
//                                } label: {
//                                    Image(systemName: "calendar")
//                                        .resizable()
//                                        .frame(width: 25, height: 25)
//                                        .foregroundColor(.black)
//                                }
//                                DatePicker(selection: $selectedDate, in: ...Date.now, displayedComponents: .date) {
//                                }
                                
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.black)
                                } .overlay {
                                    DatePicker(selection: $selectedDate, in: ...Date.now, displayedComponents: .date) {
                                    }.blendMode(.destinationOver)
                                }
                                
                                Button(action: {
                                    isSearchBarShowing = true
                                    animationVal = 0.4
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                }
                            }
                        } else {
                            Group {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.black)
                                        .padding(.leading, 10)
                                    
                                    TextField("Search", text: $searchText)
                                        .foregroundColor(.black)
                                        .padding(10)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .padding(.trailing, 10)
                                    
                                    Button(action: {
                                        isSearchBarShowing = false
                                        animationVal = 0.0
                                    }) {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.trailing, 20)
                                }
                            }
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.bottom, 10)
                    .animation(.easeInOut(duration: animationVal))
                    
                    ScrollView {
                        NavigationLink(destination: SingleDream()) {
                            VStack {
                                Text("Saturday")
                                    .foregroundStyle(.purple)
                                    .bold()
                                    .font(.system(size: 16, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1)
                                
                                HStack {
                                    Text("Driving with Dad, looking for puppies")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom, 1)
                                
                                Text("Nov 18th, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: SingleDream()) {
                            VStack {
                                Text("Friday")
                                    .foregroundStyle(.blue)
                                    .bold()
                                    .font(.system(size: 16, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1)
                                
                                HStack {
                                    Text("Joking at the pool with friends, flirting with girls")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom, 1)
                                
                                Text("Nov 17th, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: SingleDream()) {
                            VStack {
                                Text("Thursday")
                                    .foregroundStyle(.green)
                                    .bold()
                                    .font(.system(size: 16, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1)
                                
                                HStack {
                                    Text("Skating through a mall on ice skates")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom, 1)
                                
                                Text("Nov 17th, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: SingleDream()) {
                            VStack {
                                Text("Wednesday")
                                    .foregroundStyle(.red)
                                    .bold()
                                    .font(.system(size: 16, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1)
                                
                                HStack {
                                    Text("Discovering a hidden waterfall in the forest")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom, 1)
                                
                                Text("Nov 16th, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: SingleDream()) {
                            VStack {
                                Text("Tuesday")
                                    .foregroundStyle(.purple)
                                    .bold()
                                    .font(.system(size: 16, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1)
                                
                                HStack {
                                    Text("Flying with colorful balloons over a rainbow")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom, 1)
                                
                                Text("Nov 15th, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: SingleDream()) {
                            VStack {
                                Text("Monday")
                                    .foregroundStyle(.blue)
                                    .bold()
                                    .font(.system(size: 16, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 1)
                                
                                HStack {
                                    Text("Talking to a girl I knew a long time ago")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom, 1)
                                
                                Text("Nov 14th, 2023")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14, design: .serif))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 25)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: CreateDream()) {
                            Image(systemName: "pencil.and.outline")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
                            
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        
    }
}

#Preview {
    HomeView(Date.now)
}