//
//  Check_API.swift
//  argos-deepfake-guard
//
//  Created by pental on 2/7/25.
//

import Foundation

/// ✅ 사진 등록 여부 확인
func checkPhotoStatus(completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:5001/api/users/check_photos") else { return }

    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data,
           let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let result = jsonResponse["result"] as? Bool {
            DispatchQueue.main.async {
                completion(result)
            }
        } else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }.resume()
}
