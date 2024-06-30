//
//  ImageTextAttachment.swift
//  Emote
//
//  Created by Changsu Lee on 6/29/24.
//

import SwiftUI

final class ImageTextAttachment: NSTextAttachment {
    let urlString: String
    
    private struct CodingKeys {
        static var urlString: String = "urlString"
        static var height: String = "height"
    }
    
    init(urlString: String, height: CGFloat) {
        self.urlString = urlString
        super.init(data: nil, ofType: nil)
        
        initialize(height: height)
    }
    
    required init?(coder: NSCoder) {
        guard
            let urlString = coder.decodeObject(forKey: CodingKeys.urlString) as? String,
            let height = coder.decodeObject(forKey: CodingKeys.height) as? CGFloat
        else { return nil }
        
        self.urlString = urlString
        super.init(data: nil, ofType: nil)
        
        initialize(height: height)
    }
    
    override class var supportsSecureCoding: Bool { true }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(urlString, forKey: CodingKeys.urlString)
        coder.encode(bounds.height, forKey: CodingKeys.height)
    }
    
    private func initialize(height: CGFloat) {
        self.bounds = CGRect(x: 0, y: 0, width: height, height: height)
        self.image = UIImage()
        
    }
    
    func createView() -> UIHostingController<ImageView> {
        let attachmentImageView = ImageView(url: URL(string: urlString), size: .custom(bounds.size.height))
        let hostingController = UIHostingController(rootView: attachmentImageView)
        hostingController.view.frame = bounds
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}
