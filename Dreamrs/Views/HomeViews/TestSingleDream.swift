//
//  TestSingleDream.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/7/23.
//

import SwiftUI

struct TestSingleDream: View {
    @StateObject var createDreamManager = CreateDreamManager()
    var body: some View {
        VStack {
            if let t = createDreamManager.retrievedText {
                Text(AttributedString(t))
            } else {
                Text("Hello world")
            }
            
            
            Button(action: {
                // Load the text from firestore
                createDreamManager.retrieveDream()
            }) {
                Text("Load from fstore")
            }
        }.environmentObject(createDreamManager)
        
    }
}

#Preview {
    TestSingleDream()
}
