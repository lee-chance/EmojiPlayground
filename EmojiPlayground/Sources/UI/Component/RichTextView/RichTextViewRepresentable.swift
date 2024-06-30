//
//  RichTextViewRepresentable.swift
//  Emote
//
//  Created by Changsu Lee on 6/30/24.
//

import SwiftUI

protocol RichTextViewRepresentable: UIViewRepresentable where UIViewType == UITextView {
    var font: Font? { get }
}

extension RichTextViewRepresentable {
    var uiFont: UIFont {
        font.uiFont
    }
    
    // Remove old Images
    private func removeOldImages(from uiView: UIViewType) {
        uiView.subviews.forEach {
            if $0 is _UIHostingView<ImageView> {
                $0.removeFromSuperview()
            }
        }
    }
    
    // Add new Images
    private func addNewImages(to uiView: UIViewType) {
        let attributedString = uiView.attributedText!
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttribute(.attachment, in: range) { value, range, _ in
            if let attachment = value as? ImageTextAttachment {
                let glyphRange = uiView.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                let boundingRect = uiView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: uiView.textContainer)
                let view = attachment.createView().view!
                view.frame.origin = boundingRect.origin
                view.frame.origin.y += uiView.textContainerInset.top
                view.frame.origin.y += (boundingRect.height - view.frame.height).rounded() / 2
                uiView.addSubview(view)
            }
        }
    }
    
    func setImages(of uiView: UIViewType) {
        removeOldImages(from: uiView)
        addNewImages(to: uiView)
    }
}
