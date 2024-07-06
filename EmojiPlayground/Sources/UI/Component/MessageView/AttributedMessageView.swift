//
//  AttributedMessageView.swift
//  Emote
//
//  Created by Changsu Lee on 6/30/24.
//

import SwiftUI

struct AttributedMessageView: View {
    typealias IdentifiableURLString = (id: UUID, value: String)
    
    @EnvironmentObject private var settings: Settings
    @Environment(\.font) private var font
    
    @State private var style: Style?
    
    private enum Style {
        case text(_ attributedString: NSAttributedString)
        case image(_ urlString: String)
        case images(_ urlStrings: [IdentifiableURLString])
        case textWithImage(_ attributedString: NSAttributedString)
    }
    
    let message: Message
    
    var body: some View {
        switch style {
        case .text(let attr):
            RichTextMessageView(attributedText: attr, fontColor: message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
                .clipShape(.rect(cornerRadius: 12))
            
        case .image(let urlString):
            ImageView(url: URL(string: urlString), size: .middle)
            
        case .images(let urlStringList):
            HStack(spacing: 0) {
                ForEach(urlStringList, id: \.id) { urlString in
                    ImageView(url: URL(string: urlString.value), size: .small)
                }
            }
            
        case .textWithImage(let attr):
            RichTextMessageView(attributedText: attr, fontColor: message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
                .clipShape(.rect(cornerRadius: 12))
            
        // MEMO: onAppear는 1번 실행되지만 init은 여러번 실행되서 성능 이슈로 이렇게 작성하였다.
        case nil:
            Text("")
                .onAppear {
                    let data = Data(base64Encoded: message.contentValue)!
                    let attr = (try? data.attributedString()) ?? NSAttributedString()
                    let newAttr = NSMutableAttributedString(attributedString: attr)
                    let range = NSRange(location: 0, length: attr.length)
                    
                    if !attr.containsAttachments(in: range) {
                        style = .text(newAttr)
                        return
                    }
                    
                    var urlStringList = [IdentifiableURLString]()
                    var hasText = false
                    attr.enumerateAttribute(.attachment, in: range) { value, range, _ in
                        if value == nil {
                            hasText = true
                        }
                        
                        if let attachment = value as? ImageTextAttachment {
                            urlStringList.append((UUID(), attachment.urlString))
                        }
                    }
                    
                    if hasText, urlStringList.count > 0 {
                        style = .textWithImage(newAttr)
                        return
                    }
                    
                    if urlStringList.count == 1 {
                        style = .image(urlStringList[0].value)
                        return
                    } else if urlStringList.count > 6 {
                        style = .text(newAttr)
                        return
                    }
                    
                    style = .images(urlStringList)
                }
        }
    }
}

#Preview {
    @Environment(\.font) var font
    
    let photoURL = "https://firebasestorage.googleapis.com/v0/b/emote-543b9.appspot.com/o/common%2FCute%20Monsters%2FFrame%201.png?alt=media&token=f7812a72-c9ac-4cba-9cfa-59d8dbfc9f45"
    let gifURL = "https://www.easygifanimator.net/images/samples/eglite.gif"
    
    var attr_text: Message {
        let attr = NSAttributedString("Hello")
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_photo: Message {
        var attr = NSAttributedString()
        
        load(from: photoURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_gif: Message {
        var attr = NSAttributedString()
        
        load(from: gifURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_text_photo: Message {
        var attr = NSAttributedString("Hello")
        
        load(from: photoURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_text_gif: Message {
        var attr = NSAttributedString("안녕")
        
        load(from: gifURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_images: Message {
        var attr = NSAttributedString()
        
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_text_images: Message {
        var attr = NSAttributedString("jKf")
        
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_6_images: Message {
        var attr = NSAttributedString()
        
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_7_images: Message {
        var attr = NSAttributedString()
        
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_text_7_images: Message {
        var attr = NSAttributedString("Hmm..")
        
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        load(from: gifURL, attr: &attr)
        load(from: photoURL, attr: &attr)
        
        return Message(attributedString: attr, sender: .to)
    }
    
    var attr_text_100_images: Message {
        var attr = NSAttributedString("Hmm..")
        
        for _ in 0..<50 {
            load(from: photoURL, attr: &attr)
            load(from: gifURL, attr: &attr)
        }
        
        return Message(attributedString: attr, sender: .to)
    }
    
    func load(from url: String, attr: inout NSAttributedString) {
        let fontSize = font.uiFont.lineHeight
        
        let textAttachment = ImageTextAttachment(urlString: url, height: fontSize)
        let oldText = NSMutableAttributedString(attributedString: attr)
        let newGIFString = NSAttributedString(attachment: textAttachment)
        oldText.append(newGIFString)
        
        attr = oldText
    }
    
    return ScrollView {
//        AttributedMessageView(message: attr_text)
//        AttributedMessageView(message: attr_photo)
//        AttributedMessageView(message: attr_gif)
//        AttributedMessageView(message: attr_text_photo)
//        AttributedMessageView(message: attr_text_gif)
//        AttributedMessageView(message: attr_images)
//        AttributedMessageView(message: attr_text_images)
//        AttributedMessageView(message: attr_6_images)
//        AttributedMessageView(message: attr_7_images)
//        AttributedMessageView(message: attr_text_7_images)
        AttributedMessageView(message: attr_text_100_images)
    }
    .font(.largeTitle)
    .environmentObject(Settings())
}
