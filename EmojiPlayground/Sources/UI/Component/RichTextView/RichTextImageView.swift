//
//  RichTextImageView.swift
//  Emote
//
//  Created by Changsu Lee on 6/27/24.
//

import SwiftUI
import FLAnimatedImage

struct RichTextImageView: UIViewRepresentable {
    @Environment(\.font) private var font
    
    let attributedText: NSAttributedString
    let size: CGFloat
    
    var uiFont: UIFont {
        UIFont.preferredFont(from: font ?? .body)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = uiFont
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.font = uiFont
        
        // Remove old subviews (GIFs)
        uiView.subviews.forEach { if $0 is FLAnimatedImageView { $0.removeFromSuperview() } }
        
        // Add new GIF views
        addGIFViews(to: uiView)
    }
    
    private func addGIFViews(to textView: UITextView) {
        let attributedString = textView.attributedText!
        attributedString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedString.length)) { (value, range, _) in
            if let attachment = value as? GIFTextAttachment {
                let gifView = attachment.createAnimatedImageView()
                let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                let boundingRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textView.textContainer)
                gifView.frame.origin = boundingRect.origin
                gifView.frame.origin.y += textView.textContainerInset.top
                gifView.frame.origin.y += (boundingRect.height - gifView.frame.height).rounded() / 2
                textView.addSubview(gifView)
            } else if let attachment = value as? IMGTextAttachment {
                let imgView = attachment.createImageView()
                let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                let boundingRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textView.textContainer)
                imgView.frame.origin = boundingRect.origin
                imgView.frame.origin.y += textView.textContainerInset.top
                imgView.frame.origin.y += (boundingRect.height - imgView.frame.height).rounded() / 2
                imgView.frame.size = CGSize(width: size, height: size)
                textView.addSubview(imgView)
            }
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let dimensions = proposal.replacingUnspecifiedDimensions(
            by: CGSize(
                width: 0,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        
        return uiView.sizeThatFits(dimensions)
    }
}

#Preview {
    VStack {
//        RichTextImageView(attributedText: NSAttributedString(string: "yaho"))
//            .border(Color.black)
//        
//        RichTextImageView(attributedText: NSAttributedString(string: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."))
//            .border(Color.black)
    }
}
