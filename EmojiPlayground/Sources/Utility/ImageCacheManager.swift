//
//  ImageCacheManager.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/07.
//

import Foundation
import CloudKit

final class ImageCacheManager {
    static let shared = NSCache<NSString, CKAsset>()
    private init() {}
}
