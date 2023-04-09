//
//  FirebaseStorageManager.swift
//  
//
//  Created by Changsu Lee on 2023/03/02.
//

import UIKit
import FirebaseStorage

final class FirebaseStorageManager {
    static func uploadImage(image: UIImage, to path: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let imageName = "\(UUID().uuidString)_\(String(Date().timeIntervalSince1970))"
        
        let firebaseReference = Storage.storage().reference().child("\(path)/\(imageName)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    static func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        storageReference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
}
