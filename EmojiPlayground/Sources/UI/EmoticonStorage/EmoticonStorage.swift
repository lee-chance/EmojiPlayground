//
//  EmoticonStorage.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/17.
//

import Foundation
import CloudKit

@MainActor
final class EmoticonStorage: ObservableObject {
    @Published private(set) var images: [MessageImage] = []
    
    func fetchImages() async {
        do {
            images = try await MessageImage.all()
        } catch {
            print("cslog error: \(error)")
        }
    }
    
    func uploadToCommunity(image: MessageImage) {
        Task {
            do {
                guard
                    let fileURL = image.asset.fileURL,
                    let newImage = MessageImage(id: image.id, asset: CKAsset(fileURL: fileURL))
                else { return }
                
                try await CloudKitUtility.public.add(item: newImage)
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
    
    func delete(image: MessageImage) {
        Task {
            do {
                let isDeleted = try await CloudKitUtility.private.delete(item: image)
                
                if isDeleted { try await fetchImages() }
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
}
