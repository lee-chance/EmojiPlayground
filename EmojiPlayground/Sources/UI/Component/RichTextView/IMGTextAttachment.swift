//
//  IMGTextAttachment.swift
//  Emote
//
//  Created by Changsu Lee on 6/27/24.
//

import UIKit

class IMGTextAttachment: NSTextAttachment {
    let urlString: String
    
    init(urlString: String, height: CGFloat) {
        self.urlString = urlString
        super.init(data: nil, ofType: nil)
        
        initialize(height: height)
    }
    
    required init?(coder: NSCoder) {
        guard
            let urlString = coder.decodeObject(forKey: "urlString") as? String,
            let height = coder.decodeObject(forKey: "height") as? CGFloat
        else {
            return nil
        }
        
        self.urlString = urlString
        super.init(data: nil, ofType: nil)
        
        initialize(height: height)
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        // gifData를 인코딩합니다.
        coder.encode(urlString, forKey: "urlString")
        coder.encode(bounds.height, forKey: "height")
    }
    
    private func initialize(height: CGFloat) {
        self.bounds = CGRect(x: 0, y: 0, width: height, height: height)
        self.image = UIImage()
    }
    
    func createView() -> UIHostingController<AnyView> {
        let attachmentImageView = AttachmentImageView(url: URL(string: urlString), size: bounds.size)
        let hostingController = UIHostingController(rootView: AnyView(attachmentImageView))
        hostingController.view.frame = bounds
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}

import SwiftUI

private struct AttachmentImageView: View {
    let url: URL?
    let size: CGSize
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Color.clear
            case .success(let image):
                image
                    .resizable()
                    .frame(width: size.width, height: size.height)
            case .failure(let error):
                Color.blue
            @unknown default:
                Color.blue
            }
        }
    }
}
