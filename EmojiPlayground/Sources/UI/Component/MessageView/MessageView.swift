//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI

struct MessageView: CoreMessageView {
    @EnvironmentObject private var messageStore: MessageStore
    
    let message: Message
    
    @State private var presentAlert = false
    
    var body: some View {
        messageRow
            .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
            .onLongPressGesture {
                presentAlert = true
            }
            .confirmationDialog("", isPresented: $presentAlert) {
                Button("메시지 삭제", role: .destructive) {
                    Task {
                        await messageStore.delete(message: message)
                    }
                }
                
                Button("취소", role: .cancel) { }
            }
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

struct MockMessageView: CoreMessageView {
    let message: Message
    
    var body: some View {
        messageRow
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

fileprivate protocol CoreMessageView: View {
    var message: Message { get }
}

extension CoreMessageView {
    var messageRow: some View {
        HStack {
            if message.sender == .to {
                emptySpacer
            }

            switch message.contentType {
            case .plainText:
                PlainTextMessageView(message: message)
            case .image:
                ImageMessageView(message: message)
            case .attributed:
                AttributedMessageView(message: message)
            }
            
            if message.sender == .from {
                emptySpacer
            }
        }
    }
    
    private var emptySpacer: some View {
        Text(" ")
            .frame(width: Screen.width * 0.15)
    }
}

struct MessageView_Previews: PreviewProvider {
    struct Wrapper: View {
        @Environment(\.font) private var font
        
        let plain = Message(plainText: "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World", sender: .to)
        
        let image = Message(imageURLString: "https://picsum.photos/200", sender: .from)
        
        private let photoURL = "https://firebasestorage.googleapis.com/v0/b/emote-543b9.appspot.com/o/common%2FCute%20Monsters%2FFrame%201.png?alt=media&token=f7812a72-c9ac-4cba-9cfa-59d8dbfc9f45"
        private let gifURL = "https://www.easygifanimator.net/images/samples/eglite.gif"
        
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
        
        func load(from url: String, attr: inout NSAttributedString) {
            let fontSize = font.uiFont.lineHeight
            
            let textAttachment = ImageTextAttachment(urlString: url, height: fontSize)
            let oldText = NSMutableAttributedString(attributedString: attr)
            let newGIFString = NSAttributedString(attachment: textAttachment)
            oldText.append(newGIFString)
            
            attr = oldText
        }
        
        var body: some View {
            ScrollView {
                MockMessageView(message: plain)
                
                MockMessageView(message: image)
                
                MockMessageView(message: attr_text)
                MockMessageView(message: attr_photo)
                MockMessageView(message: attr_gif)
                MockMessageView(message: attr_text_photo)
                MockMessageView(message: attr_text_gif)
                MockMessageView(message: attr_images)
                MockMessageView(message: attr_text_images)
                MockMessageView(message: attr_6_images)
                MockMessageView(message: attr_7_images)
                MockMessageView(message: attr_text_7_images)
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
            .font(.largeTitle)
            .environmentObject(Settings())
    }
}
