//
//  RichTextView.swift
//  Emote
//
//  Created by Changsu Lee on 6/19/24.
//

import SwiftUI
import UIKit
import FLAnimatedImage

struct RichTextView: UIViewRepresentable {
    @Environment(\.font) private var font
    
    @Binding var attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
//        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.font = UIFont.preferredFont(from: font ?? .body)
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
//        uiView.font = UIFont.systemFont(ofSize: fontSize)
        uiView.font = UIFont.preferredFont(from: font ?? .body)
        
        // Remove old subviews (GIFs)
        uiView.subviews.forEach { if $0 is FLAnimatedImageView { $0.removeFromSuperview() } }
        
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
                textView.addSubview(gifView)
            }
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let dimensions = proposal.replacingUnspecifiedDimensions(
            by: .init(
                width: 0,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
                
        let calculatedHeight = calculateTextViewHeight(
            containerSize: dimensions,
            attributedString: uiView.attributedText
        )
        
        return .init(
            width: dimensions.width,
            height: calculatedHeight + 0
        )
    }
    
    private func calculateTextViewHeight(containerSize: CGSize,
                                         attributedString: NSAttributedString) -> CGFloat {
        let boundingRect = attributedString.boundingRect(
            with: .init(width: containerSize.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return boundingRect.height + 0
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView
        
        init(_ parent: RichTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
    }
}

#Preview {
    @State var hi = NSAttributedString(string: "hmm")
    
    return RichTextView(attributedText: $hi)
}
