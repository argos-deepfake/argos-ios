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
            checkPhotoStatus { result in
                self.isPhotoRegistered = result
            }
        }
    }
    
    /// ✅ **사진이 등록된 경우의 뷰**
    var registeredPhotoView: some View {
        VStack(spacing: 20) {
            Text("✅방어 할 사진을 선택해 주세요✅")
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
            Text("📌 4장의 사진을 먼저 등록하세요. 📌")
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
    
    
    /// ✅ 4장 업로드 API 호출
    func uploadFourPhotos() {
        isProcessing = true
        argos_deepfake_guard.uploadFourPhotos(images: selectedImages) { success, message in
            isProcessing = false
            if success {
                self.isPhotoRegistered = true
            } else {
                self.alertMessage = message ?? "업로드 실패"
                self.showAlert = true
            }
        }
    }
    
    /// ✅ FakeGuard 실행 API 호출
    func uploadPhoto() {
        guard let selectedImage = selectedImages.first else { return }
        isProcessing = true
        
        argos_deepfake_guard.uploadPhoto(image: selectedImage) { image, message in
            isProcessing = false
            if let resultImage = image {
                self.resultImage = resultImage
                self.navigateToResult = true
            } else {
                self.alertMessage = message ?? "오류 발생"
                self.showAlert = true
            }
        }
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
