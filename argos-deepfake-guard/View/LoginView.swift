//
//  LoginView.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/6/25.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            if isLoggedIn {
                FakeGuardView()
            } else {
                VStack(spacing: 16) {
                    Image("Argos-Main-Logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding()
                    
                    TextField("아이디", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("비밀번호", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: login) {
                        Text("로그인")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                NavigationLink(destination: SignupView()) {
                    Text("아직 회원이 아니신가요? 회원가입하기")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    func login() {
        guard let url = URL(string: "http://127.0.0.1:5001/api/users/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   jsonResponse["message"] as? String == "Login successful" {
                    DispatchQueue.main.async {
                        isLoggedIn = true
                    }
                }
            }
        }.resume()
    }
}
