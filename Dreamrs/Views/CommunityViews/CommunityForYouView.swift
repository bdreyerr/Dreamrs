//
//  CommunityForYouView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/5/24.
//

import SwiftUI

struct CommunityForYouView: View {
    var body: some View {
        Text("The For You page is not available just yet, check back soon!")
            .italic()
            .font(.system(size: 15, design: .serif))
            .accentColor(.black)
            .padding(.top, 40)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}

#Preview {
    CommunityForYouView()
}
