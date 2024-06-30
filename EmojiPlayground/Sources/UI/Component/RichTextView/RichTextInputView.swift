//
//  RichTextInputView.swift
//  Emote
//
//  Created by Changsu Lee on 6/19/24.
//

import SwiftUI

struct RichTextInputView: RichTextViewRepresentable {
    @Environment(\.font) var font
    
    @Binding var attributedText: NSAttributedString
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
        
        setImages(of: uiView)
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

extension RichTextInputView {
    final class Coordinator: NSObject {
        var parent: RichTextInputView
        
        init(_ parent: RichTextInputView) {
            self.parent = parent
        }
    }
}

extension RichTextInputView.Coordinator: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        parent.attributedText = textView.attributedText
    }
}

#Preview {
    @State var hi = NSAttributedString(string: "hmm")
    
    return RichTextInputView(attributedText: $hi)
}
