//
//  BottomNavBar.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 10/28/23.
//

import SwiftUI

struct BottomNavBar: View {
    var body: some View {
        ZStack {
            TabView() {
                Group() {
                    HomeView(Date.now)
                        .tabItem {
                            Label("", systemImage: "house")
                        }
                    
                    CommunityMainView()
                        .tabItem {
                            Label("", systemImage: "person.3.fill")
                        }
                    
                    ProfileMainView()
                        .tabItem {
                            Label("", systemImage: "person.fill")
                        }
                }
//                .toolbarBackground(.visible, for:.tabBar)
                .toolbarColorScheme(.none, for: .tabBar)
                .toolbarBackground(.hidden, for: .tabBar)
            }
        }
    }
}

struct BottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavBar()
    }
}
