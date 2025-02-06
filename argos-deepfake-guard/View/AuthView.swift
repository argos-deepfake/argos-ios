//
//  AuthView.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/6/25.
//

import SwiftUI

struct AuthView: View {
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Login Mode", selection: $isLoginMode) {
                    Text("로그인").tag(true)
                    Text("회원가입").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isLoginMode {
                    LoginView()
                } else {
                    SignupView()
                }
            }
//            .navigationTitle(isLoginMode ? "ARGOS DEEPFAKE GUARD" : "회원가입")
            .animation(.easeInOut, value: isLoginMode)
        }
    }
}
