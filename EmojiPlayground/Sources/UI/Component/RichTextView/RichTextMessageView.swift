//
//  RichTextMessageView.swift
//  Emote
//
//  Created by Changsu Lee on 6/19/24.
//

import SwiftUI

struct RichTextMessageView: RichTextViewRepresentable {
    @Environment(\.font) var font
    
    let attributedText: NSAttributedString
    let fontColor: Color
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: false)
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
        let newAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let range = NSRange(location: 0, length: attributedText.length)
        newAttributedText.addAttribute(.foregroundColor, value: UIColor(fontColor), range: range)
        uiView.attributedText = newAttributedText
        uiView.font = uiFont
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let dimensions = proposal.replacingUnspecifiedDimensions(
            by: CGSize(
                width: 0,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        
        // MEMO: Task 블럭으로 감싸면 sizeThatFits 이후에 동작하는 큐가 추가되어 실행된다.
        Task { setImages(of: uiView) }
        
        return uiView.sizeThatFits(dimensions)
    }
}

#Preview {
    VStack {
        RichTextMessageView(attributedText: NSAttributedString(string: "yaho"), fontColor: .blue)
            .border(Color.black)
        
        RichTextMessageView(attributedText: NSAttributedString(string: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."), fontColor: .blue)
            .border(Color.black)
    }
}
