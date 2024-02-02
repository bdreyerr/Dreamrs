//
//  WelcomeSurveyView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 1/15/24.
//

import SwiftUI

struct WelcomeSurveyView: View {
    
    @EnvironmentObject var userManager: UserManager
    @StateObject var welcomeSurveyManager = WelcomeSurveyManager()
    
    
    var body: some View {
        ZStack {
            Color.white // Background
                .ignoresSafeArea()
            VStack {
                // Logo and settings
                HStack {
                    Image("home_logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    Text("D R E A M R S")
                        .font(.system(size: 14))
                        .padding(.trailing, 20)
                    //                            .padding(.bottom, 5)
                        .font(.subheadline)
                        .bold()
                        .padding(.trailing, 40)
                }
                .padding(.bottom, 40)
                
                Text("Welcome! We need some info before you begin your dream journey:")
                    .font(.system(size: 16))
                    .fontDesign(.serif)
                    .foregroundStyle(Color.black)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                
                HStack {
                    TextField("Handle", text: $welcomeSurveyManager.handle)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 16))
                        .frame(maxWidth: 150, alignment: .leading)
                        .fontDesign(.serif)
                        .foregroundStyle(welcomeSurveyManager.convertColorStringToView())
                        .padding(.leading, 20)
                        .textInputAutocapitalization(.never)
                    
                    
                    Picker("", selection: $welcomeSurveyManager.userColor) {
                        ForEach(welcomeSurveyManager.colorOptions, id: \.self) { color in
                            Text(color)
                                .foregroundStyle(Color.red)
                        }
                    }
                    .pickerStyle(.automatic)
                    .frame(maxWidth: 150, alignment: .leading)
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 100)
                
                
                if welcomeSurveyManager.isLoadingWheelVisisble {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(2)  // Adjust size if needed
                        .animation(.linear(duration: 1.0).repeatForever(autoreverses: true))
                        .padding(.bottom, 20)
                }
                
                
                if welcomeSurveyManager.errorString != "" {
                    Text(welcomeSurveyManager.errorString)
                        .font(.system(size: 16))
                        .fontDesign(.serif)
                        .foregroundStyle(Color.red)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                }
                
                
                
                Button(action: {
                    welcomeSurveyManager.completeWelcomeSurvey()
                    // Re-load the user manager to get rid of the welcome survey view - but wait 2 seconds (spagehtti code rip)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                        userManager.retrieverUserFromFirestore(userId: userManager.user!.id!)
                    }
                    
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(.black).opacity(0.5), lineWidth: 1)
                        )
                }
                
                
                
                
                Spacer()
                
            }
            
            
        }
        .environmentObject(welcomeSurveyManager)
        .environmentObject(userManager)
    }
}

#Preview {
    WelcomeSurveyView()
        .environmentObject(WelcomeSurveyManager())
        .environmentObject(UserManager())
}
