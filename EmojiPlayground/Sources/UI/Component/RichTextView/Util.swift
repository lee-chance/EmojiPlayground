//
//  Util.swift
//  Emote
//
//  Created by Changsu Lee on 6/27/24.
//

// MARK: 언젠간 쓸수도 있잖아...⭐️

//import SwiftUI
//import MobileCoreServices
//import UniformTypeIdentifiers
//
//extension Data {
//    var isGIF: Bool {
//        guard
//            let source = CGImageSourceCreateWithData(self as CFData, nil),
//            let type = CGImageSourceGetType(source)
//        else { return false }
//        
//        if #available(iOS 14.0, *) {
//            return UTType(type as String) == UTType.gif
//        } else {
//            return UTTypeConformsTo(type, kUTTypeGIF)
//        }
//    }
//}
//
//extension UIImage {
//    func imageWith(newSize: CGSize) -> UIImage {
//        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
//            draw(in: CGRect(origin: .zero, size: newSize))
//        }
//        
//        return image.withRenderingMode(renderingMode)
//    }
//    
//    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
//        
//        guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
//        defer { UIGraphicsEndImageContext() }
//        
//        let rect = CGRect(origin: .zero, size: size)
//        ctx.setFillColor(color.cgColor)
//        ctx.fill(rect)
//        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
//        ctx.draw(image, in: rect)
//        
//        return UIGraphicsGetImageFromCurrentImageContext() ?? self
//    }
//}
