//
//  EmoticonStorage.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/05/29.
//

import Foundation
import CloudKit

@MainActor
final class EmoticonStorage: ObservableObject {
    @Published private(set) var images: [MessageImage] = []
    
    func groupedImages() -> [GroupedImage] {
        Dictionary(grouping: images, by: { $0.groupName ?? " " })
            .sorted(by: { $0.key > $1.key })
            .map { GroupedImage(name: $0.key, images: $0.value) }
    }
    
    func groupImages(groupName: String) -> [MessageImage] {
        images.filter { $0.groupName ?? " " == groupName }
    }
    
    var groupNames: [String] {
        Array(Set(images.compactMap { $0.groupName }))
            .sorted()
    }
    
    init() {
        Task { await fetchImages() }
    }
    
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

struct GroupedImage: Identifiable, Hashable {
    let name: String
    let images: [MessageImage]
    
    var id: String { name }
}
