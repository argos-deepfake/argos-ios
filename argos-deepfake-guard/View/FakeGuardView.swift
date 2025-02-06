import SwiftUI
import PhotosUI

struct FakeGuardView: View {
    @State private var isPhotoRegistered: Bool? = nil
    @State private var selectedImages: [UIImage] = []
    @State private var resultImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var navigateToResult = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if let isPhotoRegistered = isPhotoRegistered {
                    if isPhotoRegistered {
                        registeredPhotoView
                    } else {
                        uploadFourPhotosView
                    }
                } else {
                    loadingView
                }
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(images: $selectedImages, maxImages: isPhotoRegistered == false ? 4 : 1)
            }
            .background(
                NavigationLink(destination: FakeGuardResultView(resultImage: resultImage ?? UIImage()), isActive: $navigateToResult) {
                    EmptyView()
                }
                    .hidden()
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            checkPhotoStatus()
        }
    }
    
    /// ✅ **사진이 등록된 경우의 뷰**
    var registeredPhotoView: some View {
        VStack(spacing: 20) {
            Text("등록된 사진이 있습니다. 한 장을 업로드하세요.")
                .font(.title2)
                .padding()
            
            if let image = selectedImages.first {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
            
            Button(action: { showingImagePicker.toggle() }) {
                Text(selectedImages.isEmpty ? "📷 사진 선택" : "📷 다른 사진 선택")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isProcessing)
            
            if !selectedImages.isEmpty {
                Button(action: { uploadPhoto() }) {
                    Text("🚀 FakeGuard 실행")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isProcessing)
            }
            
            if isProcessing {
                ProgressView("분석 중...").padding()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    /// ✅ **사진이 등록되지 않은 경우 4장을 업로드하는 뷰**
    var uploadFourPhotosView: some View {
        VStack(spacing: 20) {
            Text("📌 FakeGuard를 사용하려면\n4장의 사진을 먼저 등록하세요.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
            
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 5)
                        }
                    }
                }
                .padding()
            }
            
            Button(action: { showingImagePicker.toggle() }) {
                Text(selectedImages.isEmpty ? "📷 사진 4장 선택" : "📷 다른 사진 선택")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isProcessing)
            
            if selectedImages.count == 4 {
                Button(action: { uploadFourPhotos() }) {
                    Text("🚀 사진 4장 업로드")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isProcessing)
            }
        }
    }
    
    /// ✅ **로딩 화면**
    var loadingView: some View {
        VStack {
            ProgressView("사진 정보를 불러오는 중...")
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
        }
    }
    
    /// ✅ 사진 등록 여부 확인
    func checkPhotoStatus() {
        guard let url = URL(string: "http://127.0.0.1:5001/api/users/check_photos") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data,
               let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = jsonResponse["result"] as? Bool {
                DispatchQueue.main.async {
                    self.isPhotoRegistered = result
                }
            } else {
                DispatchQueue.main.async {
                    self.isPhotoRegistered = false
                }
            }
        }.resume()
    }
    
    /// ✅ 4장 업로드 API 호출
    func uploadFourPhotos() {
        guard let url = URL(string: "http://127.0.0.1:5001/api/users/upload_photo") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        for image in selectedImages {
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
        
        URLSession.shared.uploadTask(with: request, from: body) { data, response, _ in
            if let data = data, let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let successMessage = response["message"] as? String {
                DispatchQueue.main.async {
                    print("✅ 성공: \(successMessage)")
                    self.isPhotoRegistered = true
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ 업로드 실패")
                }
            }
        }.resume()
    }
    
    /// ✅ FakeGuard 실행
    func uploadPhoto() {
        guard let selectedImage = selectedImages.first,
              let url = URL(string: "http://127.0.0.1:5001/api/users/fakeguard") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let fieldName = "file"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        isProcessing = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            
            if let data = data,
               let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let previewUrl = jsonResponse["preview_url"] as? String,
               let imageUrl = URL(string: "http://127.0.0.1:5001\(previewUrl)") {
                
                if let imageData = try? Data(contentsOf: imageUrl), let resultImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.resultImage = resultImage
                        self.navigateToResult = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ FakeGuard 처리 중 오류 발생"
                }
            }
        }.resume()
    }
}

/// ✅ 사진 선택을 위한 ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    let maxImages: Int
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = maxImages
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // ✅ 기존 사진 초기화 후 새로운 사진 추가
            parent.images.removeAll()

            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self = self else { return } // ✅ self를 약한 참조로 캡처

                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(uiImage)
                        }
                    }
                }
            }
        }
    }


}
