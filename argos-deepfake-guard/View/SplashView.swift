//
//  SplashView.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/8/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        Group {
            if isActive {
                LoginView() // 실제 로그인 화면
            } else {
                VStack {
                    Image(systemName: "shield.lefthalf.filled") // 로고
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Argos Deepfake Guard")
                        .font(.title)
                        .bold()
                        .padding(.top, 10)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    SplashView()
}
