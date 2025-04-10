//
//  HomeView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 11/19/23.
//

import SwiftUI
import FirebaseAuth
import UIKit

struct HomeView: View {
    
    @StateObject var homeManager = HomeManager()
    @EnvironmentObject var userManager: UserManager
    @State private var showFilterView = false
    @State private var showSearchBar = false
    @State private var searchText = ""
    @State private var isNewestSelected = true
    @State private var isOldestSelected = false
    
    var filteredDreams: [Dream] {
        if searchText.isEmpty {
            return homeManager.retrievedDreams
        } else {
            return homeManager.retrievedDreams.filter { dream in
                if let title = dream.title {
                    return title.lowercased().contains(searchText.lowercased())
                }
                return false
            }
        }
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
                        
                        Text("D R E A M R S")
                            .font(.system(size: 14))
                            .padding(.trailing, 20)
                            .font(.subheadline)
                            .bold()
                        
//                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    
                    // Filters and search
                    HStack(spacing: 16) {
                        Spacer()
                        // Filters button
                        Button(action: {
                            withAnimation {
                                showFilterView.toggle()
                                if showSearchBar { showSearchBar = false }
                            }
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(showFilterView ? .blue : .primary)
                        }
                        
                        // Search button
                        Button(action: {
                            withAnimation {
                                showSearchBar.toggle()
                                if showFilterView { showFilterView = false }
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18))
                                .foregroundColor(showSearchBar ? .blue : .primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    // Search bar
                    if showSearchBar {
                        SearchBar(text: $searchText, placeholder: "Search dreams...")
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Filter view
                    if showFilterView {
                        HStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Filters")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                HStack {
                                    FilterChip(title: "Newest", isSelected: $isNewestSelected, action: {
                                        isNewestSelected = true
                                        isOldestSelected = false
                                        homeManager.toggleSortOrder(isNewest: true)
                                    })
                                    FilterChip(title: "Oldest", isSelected: $isOldestSelected, action: {
                                        isNewestSelected = false
                                        isOldestSelected = true
                                        homeManager.toggleSortOrder(isNewest: false)
                                    })
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    
                    ScrollView(showsIndicators: false) {
                        if homeManager.retrievedDreams.isEmpty {
                            Image("sleep_face")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .opacity(0.6)
                                .padding(.top, 60)
                        } else if !searchText.isEmpty && filteredDreams.isEmpty {
                            VStack {
                                Image("sleep_face")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .opacity(0.4)
                                    .padding(.top, 60)
                                
                                Text("No dreams match your search")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                            }
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredDreams) { dream in
                                    ListDream(dream: dream, title: dream.title!, date: dream.date!, dayOfWeek: dream.dayOfWeek!)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                        }
                        
                        
                        if !homeManager.retrievedDreams.isEmpty && homeManager.noMoreDreamsAvailable == false && self.searchText.isEmpty {
                            // More Dreams Button
                            Button(action: {
                                homeManager.loadMoreDreams()
                            }) {
                                if homeManager.isLoadingMoreDreams {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                                                          startPoint: .leading,
                                                          endPoint: .trailing)
                                        )
                                        .cornerRadius(20)
                                } else {
                                    Text(homeManager.noMoreDreamsAvailable ? "No More Dreams" : "More Dreams")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [
                                                homeManager.noMoreDreamsAvailable ? Color.gray.opacity(0.7) : Color.blue.opacity(0.7),
                                                homeManager.noMoreDreamsAvailable ? Color.gray.opacity(0.7) : Color.purple.opacity(0.7)
                                            ]),
                                                          startPoint: .leading,
                                                          endPoint: .trailing)
                                        )
                                        .cornerRadius(20)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                            .disabled(homeManager.isLoadingMoreDreams || homeManager.noMoreDreamsAvailable)
                            .padding(.horizontal, 150)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        }
                        
                    }
                    .padding(.top, 5)
                    
                    
                    
                }
                .scrollDismissesKeyboard(.interactively)
                .padding(.top, 10)
                .padding(.bottom, 25)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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
            // Initialize sort order based on UI selection
            homeManager.sortByDateDescending = isNewestSelected
            
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

struct FilterChip: View {
    var title: String
    @Binding var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5))
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(16)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
