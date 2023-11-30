//
//  Community.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/17.
//

import Foundation

@MainActor
final class Community: ObservableObject {
    @Published private(set) var images: [Emoticon] = []
    
//    func fetchImages() async {
//        do {
//            images = try await MessageImage.allPublic()
//        } catch {
//            print("cslog error: \(error)")
//        }
//    }
}
