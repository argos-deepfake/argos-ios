//
//  FakeGuardResultView.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/6/25.
//

import Foundation
import SwiftUI
import Photos

struct FakeGuardResultView: View {
    let resultImage: UIImage
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text("FakeGuard 결과")
                .font(.title)
                .padding()

            Image(uiImage: resultImage)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()

            // ✅ "갤러리에 저장" 버튼
            Button(action: saveImageToGallery) {
                Text("📥 갤러리에 저장")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }

    /// ✅ 갤러리에 저장하는 함수 (권한 확인 포함)
    func saveImageToGallery() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            saveImage()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    saveImage()
                } else {
                    alertMessage = "갤러리 접근이 거부되었습니다. 설정에서 권한을 허용해주세요."
                    showAlert = true
                }
            }
        default:
            alertMessage = "갤러리 접근이 거부되었습니다. 설정에서 권한을 허용해주세요."
            showAlert = true
        }
    }

    /// ✅ 실제 이미지 저장 함수
    private func saveImage() {
        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil)
        alertMessage = "사진이 갤러리에 저장되었습니다!"
        showAlert = true
    }
}
