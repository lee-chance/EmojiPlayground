//
//  ImagePicker.swift
//
//
//  Created by Changsu Lee
//

import SwiftUI

typealias imageURLFromImagePicker = (url: URL, ext: String)

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var mode
    
    let callback: (imageURLFromImagePicker) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

extension ImagePicker {
    final class Coordinator: NSObject {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
}

extension ImagePicker.Coordinator: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let url = info[.imageURL] as? NSURL,
            let absoluteURL = url.absoluteURL,
            let ext = url.pathExtension
        else { return }
        
        parent.callback((absoluteURL, ext))
        parent.mode.wrappedValue.dismiss()
    }
}


//import PhotosUI
//
////typealias imageDataFromPhotoPicker = (data: Data, ext: String)
//typealias imageURLFromPhotoPicker = (url: URL, ext: String)
//
//struct PhotoPicker: UIViewControllerRepresentable {
//    let configuration: PHPickerConfiguration
//    let callback: (imageURLFromPhotoPicker) -> Void
//    @Environment(\.presentationMode) var mode
//
//    init(configuration: PHPickerConfiguration, callback: @escaping (imageURLFromPhotoPicker) -> Void) {
//        self.configuration = configuration
//        self.callback = callback
//    }
//
//    init(callback: @escaping (imageURLFromPhotoPicker) -> Void) {
//        self.configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
//        self.callback = callback
//    }
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        let controller = PHPickerViewController(configuration: configuration)
//        controller.delegate = context.coordinator
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // Use a Coordinator to act as your PHPickerViewControllerDelegate
//    class Coordinator: PHPickerViewControllerDelegate {
//        private let parent: PhotoPicker
//
//        init(_ parent: PhotoPicker) {
//            self.parent = parent
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            for result in results {
////                result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
////                    print("data: \(data)")
////                    print("error: \(error)")
////                    guard let data = data else { return } // TODO: 이미지 확장자로 분기처리
////                    self.parent.callback((data, ""))
////                }
//
////                result.itemProvider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, b, error in
////                    print("url: \(url)")
////                    print("b: \(b)")
////                    print("error: \(error)")
////                    guard let url = url else { return }
////                    self.parent.callback(imageURLFromPhotoPicker(url: url, ext: url.pathExtension))
////                }
//
////                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.item") { url, error in
////                    guard let url = url else { return }
////                    self.parent.callback(imageURLFromPhotoPicker(url: url, ext: url.pathExtension))
////                }
//            }
//
//            parent.mode.wrappedValue.dismiss()
//        }
//    }
//}
