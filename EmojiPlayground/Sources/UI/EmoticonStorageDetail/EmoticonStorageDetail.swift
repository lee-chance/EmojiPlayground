//
//  EmoticonStorageDetail.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/05/29.
//

import Foundation
import CloudKit

@MainActor
final class EmoticonStorageDetail: ObservableObject {
    let name: String
    
    @Published private(set) var images: [MessageImage] = []
    
    init(name: String) {
        self.name = name
        Task { await fetchImages() }
    }
    
    func fetchImages() async {
        do {
            let allImages = try await MessageImage.all()
            images = allImages.filter { $0.groupName ?? " " == name }
        } catch {
            print("cslog error: \(error)")
        }
    }
    
    func uploadToCommunity(image: MessageImage) {
        Task {
            do {
                guard let newImage = image.clone() else { return }
                
                try await CloudKitUtility.public.add(item: newImage)
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
    
    func update(image: MessageImage, groupName: String) {
        Task {
            do {
                guard let newImage = image.clone(groupName: groupName) else { return }
                
                let isUpdated = try await CloudKitUtility.private.update(item: newImage)
                
                if isUpdated { delete(image: image) }
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
    
    func delete(image: MessageImage) {
        Task {
            do {
                let isDeleted = try await CloudKitUtility.private.delete(item: image)
                
                if isDeleted { await fetchImages() }
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
}
