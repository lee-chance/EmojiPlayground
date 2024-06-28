//
//  RichTextView.swift
//  Emote
//
//  Created by Changsu Lee on 6/19/24.
//

import SwiftUI
import FLAnimatedImage

struct RichTextView: UIViewRepresentable {
    @Environment(\.font) private var font
    
    @Binding var attributedText: NSAttributedString
    
    private var uiFont: UIFont {
        UIFont.preferredFont(from: font ?? .body)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        textView.font = uiFont
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.font = uiFont
        
        // Remove old subviews (GIFs and IMGs)
        uiView.subviews.forEach { if $0 is FLAnimatedImageView { $0.removeFromSuperview() } }
        uiView.subviews.forEach { if $0 is _UIHostingView<AnyView> { $0.removeFromSuperview() } }
        
        // Add new GIF views
        addGIFViews(to: uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
                let imgView = attachment.createView().view!
                let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                let boundingRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textView.textContainer)
                imgView.frame.origin = boundingRect.origin
                imgView.frame.origin.y += textView.textContainerInset.top
                imgView.frame.origin.y += (boundingRect.height - imgView.frame.height).rounded() / 2
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
        
        return CGSize(width: dimensions.width, height: uiView.sizeThatFits(dimensions).height)
    }
}

extension RichTextView {
    final class Coordinator: NSObject {
        var parent: RichTextView
        
        init(_ parent: RichTextView) {
            self.parent = parent
        }
    }
}

extension RichTextView.Coordinator: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        parent.attributedText = textView.attributedText
    }
}

#Preview {
    @State var hi = NSAttributedString(string: "hmm")
    
    return RichTextView(attributedText: $hi)
}
