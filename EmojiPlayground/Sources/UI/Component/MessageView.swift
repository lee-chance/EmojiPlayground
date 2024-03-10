//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

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


fileprivate struct PlainTextMessageView: View {
    @EnvironmentObject private var settings: Settings
    
    let message: Message
    
    var body: some View {
        Text(message.contentValue)
            .foregroundStyle(message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
            .padding(12)
            .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
            .clipShape(.rect(cornerRadius: 12))
    }
}

fileprivate struct ImageMessageView: View {
    @EnvironmentObject private var settings: Settings
    
    @State private var isLoadSuccessed = false
    
    let message: Message
    
    var body: some View {
        WebImage(url: message.imageURL)
            .resizable()
            .placeholder {
                Rectangle()
                    .foregroundStyle(.black.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .onSuccess { _, _, _ in
                isLoadSuccessed = true
            }
            .aspectRatio(settings.imageRatioType.ratio, contentMode: .fit)
            .frame(width: 150, height: 150)
            .background {
                if isLoadSuccessed {
                    Rectangle()
                        .foregroundStyle(settings.imageBackgroundColor)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

struct MessageView_Previews: PreviewProvider {
    struct Wrapper: View {
        var body: some View {
            let msg = Message(plainText: "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World", sender: .to)
            MessageView(message: msg)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
