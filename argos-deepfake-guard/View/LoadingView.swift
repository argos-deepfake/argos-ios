//
//  LoadingView.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/7/25.
//

import Foundation
import SwiftUI

/// ✅ **로딩 화면**
var loadingView: some View {
    VStack {
        ProgressView("사진 정보를 불러오는 중...")
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.5)
            .padding()
    }
}
