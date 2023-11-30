//
//  FirebaseStorageManager.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/29.
//

import UIKit
import FirebaseStorage

final class FirebaseStorageManager {
    private static let storage = Storage.storage()
    
    static func upload(data: Data, to path: String) async -> URL? {
        let metadata = StorageMetadata()
        metadata.contentType = data.mimeType
        let imageName = UUID().uuidString
        let firebaseReference = storage.reference().child("\(path)/\(imageName)")
        do {
            let _ = try await firebaseReference.putDataAsync(data, metadata: metadata)
            let url = try await firebaseReference.downloadURL()
            return url
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
