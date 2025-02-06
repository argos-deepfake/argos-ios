//
//  Upload_API.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/7/25.
//

import Foundation
import UIKit

/// ✅ 4장의 사진을 업로드하는 API 호출
func uploadFourPhotos(images: [UIImage], completion: @escaping (Bool, String?) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:5001/api/users/upload_photo") else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    for image in images {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let fieldName = "file"  // ✅ 모든 파일을 동일한 "file" 필드로 전송
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
    }
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body

    URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
        if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let successMessage = jsonResponse["message"] as? String {
            DispatchQueue.main.async {
                completion(true, successMessage)
            }
        } else {
            DispatchQueue.main.async {
                completion(false, "❌ 업로드 실패")
            }
        }
    }.resume()
}

/// ✅ FakeGuard 실행 API 호출
func uploadPhoto(image: UIImage, completion: @escaping (UIImage?, String?) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:5001/api/users/fakeguard") else {
        completion(nil, "❌ 잘못된 URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    if let imageData = image.jpegData(compressionQuality: 0.8) {
        let fieldName = "file"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
    }
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data,
           let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let previewUrl = jsonResponse["preview_url"] as? String,
           let imageUrl = URL(string: "http://127.0.0.1:5001\(previewUrl)"),
           let imageData = try? Data(contentsOf: imageUrl),
           let resultImage = UIImage(data: imageData) {
            DispatchQueue.main.async {
                completion(resultImage, nil)
            }
        } else {
            DispatchQueue.main.async {
                completion(nil, "❌ FakeGuard 처리 중 오류 발생")
            }
        }
    }.resume()
}
