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
    var body: some View {
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
                .padding(.top, 150)
                
                Spacer()
                
                
                ZStack {
                    
                    Image("register")
                        .resizable()
                        .frame(width: 400, height: 400)
                        .cornerRadius(20.0)
                        .offset(y: 30)
                    
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            //                        let nonce = authStateManager.randomNonceString()
                            //                        authStateManager.currentNonce = nonce
                            //                        request.requestedScopes = [.fullName, .email]
                            //                        request.nonce = authStateManager.sha256(nonce)
                        },
                        onCompletion: { result in
                            //                        authStateManager.appleSignInButtonOnCompletion(result: result)
                        }
                    ).frame(width: 350, height: 60)
                        .cornerRadius(50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.white, lineWidth: 1))
                        .padding(.top, 300)
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
