//
//  Util.swift
//  Emote
//
//  Created by Changsu Lee on 6/27/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

extension Data {
    var isGIF: Bool {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil) else { return false }
        guard let type = CGImageSourceGetType(source) else { return false }
        
        if #available(iOS 14.0, *) {
            return UTType(type as String) == UTType.gif
        } else {
            return UTTypeConformsTo(type, kUTTypeGIF)
        }
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return image.withRenderingMode(renderingMode)
    }
}
