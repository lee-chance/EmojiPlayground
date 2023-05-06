//
//  ImagePicker.swift
//
//
//  Created by Changsu Lee
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let perform: (_ imageURL: URL) -> Void
    
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
        guard let url = info[.imageURL] as? URL else { return }
        
        parent.perform(url)
        parent.dismiss()
    }
}
