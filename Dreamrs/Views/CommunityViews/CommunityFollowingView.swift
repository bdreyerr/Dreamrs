//
//  CommunityFollowingView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/5/24.
//

import SwiftUI

struct CommunityFollowingView: View {
    
    @EnvironmentObject var communityManager: CommunityManager
    
    var body: some View {
        VStack {
            ScrollView {
                // Display dreams based on time frame selection
                if communityManager.selectedTimeFilter == communityManager.timeFilters[0] {
                    ForEach(communityManager.retrievedDreamsToday) { dream in
                        CommunityDream(dream: dream, title: dream.title!, handle: dream.authorHandle!, date: dream.date!, karma: dream.karma!)
                    }
                } else if communityManager.selectedTimeFilter == communityManager.timeFilters[1] {
                    ForEach(communityManager.retrievedDreamsThisMonth) { dream in
                        CommunityDream(dream: dream, title: dream.title!, handle: dream.authorHandle!, date: dream.date!, karma: dream.karma!)
                    }
                }
                
            }
        }
        .padding(.leading, 20)
    }
}

#Preview {
    CommunityFollowingView()
        .environmentObject(CommunityManager())
}
