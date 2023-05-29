//
//  EmoticonStorageMain.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/17.
//

import Foundation
import CloudKit

@MainActor
final class EmoticonStorageMain: ObservableObject {
    @Published private(set) var images: [MessageImage] = []
    
    func fetchImages() async {
        do {
            images = try await MessageImage.all()
        } catch {
            print("cslog error: \(error)")
        }
    }
}
