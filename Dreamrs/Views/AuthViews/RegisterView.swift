//
//  RegisterView.swift
//  Dreamrs
//
//  Created by Ben Dreyer on 12/2/23.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Color.white // Background
            VStack {
                // Logo
                HStack {
                    Image("home_logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                    Text("D R E A M R S")
                        .font(.system(size: 14))
                        .padding(.trailing, 20)
                        .padding(.bottom, 15)
                        .font(.subheadline)
                        .bold()
                }
                .padding(.top, 150)
                
                Spacer()
                
                
                ZStack {
                    
                    Image("register")
                        .resizable()
                        .frame(width: 500, height: 500)
                        .cornerRadius(20.0)
                        .offset(y: 35)
                    
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = authManager.randomNonceString()
                            authManager.currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = authManager.sha256(nonce)
                        },
                        onCompletion: { result in
                            authManager.appleSignInButtonOnCompletion(result: result)
                        }
                    ).frame(width: 350, height: 60)
                        .cornerRadius(50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.white, lineWidth: 1))
                        .padding(.top, 350)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
}
