//
//  CachedImage.swift
//  Emote
//
//  Created by Changsu Lee on 6/30/24.
//

import UIKit

@MainActor
final class CachedImage {
    static let shared = CachedImage()
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    
    func load(forKey key: URL?) -> UIImage? {
        guard let key = key?.absoluteString else { return nil }
        return cache.object(forKey: key as NSString)
    }
    
    func save(_ image: UIImage, forKey key: URL) {
        cache.setObject(image, forKey: key.absoluteString as NSString)
    }
}
