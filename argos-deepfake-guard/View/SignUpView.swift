//
//  SignUpView.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/6/25.
//

import Foundation
import SwiftUI

struct SignupView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("아이디", text : $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("이메일", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                
            Button(action: signup) {
                Text("회원가입")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func signup() {
        guard let url = URL(string: "http://127.0.0.1:5001/api/users/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters = ["username": username, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print(jsonResponse)
                }
            }
        }.resume()
    }
}
