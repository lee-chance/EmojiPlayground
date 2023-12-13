//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: View {
    @EnvironmentObject private var messageStore: MessageStore
    @EnvironmentObject private var mainRounter: MainRouter
    
    let message: Message
    
    @State private var presentAlert = false
    
    var body: some View {
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
        .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
        .onLongPressGesture {
            if message.sender == .to {
                presentAlert = true
            }
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
    
    private var emptySpacer: some View {
        Text(" ")
            .frame(width: Screen.width * 0.15)
    }
}

extension MessageView {
    struct PlainTextMessageView: View {
        @EnvironmentObject private var theme: Theme
        
        let message: Message
        
        var body: some View {
            Text(message.contentValue)
                .foregroundStyle(message.sender == .to ? theme.myMessageFontColor : theme.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .to ? theme.myMessageBubbleColor : theme.otherMessageBubbleColor)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    struct ImageMessageView: View {
        let message: Message
        
        var body: some View {
            WebImage(url: message.imageURL)
                .resizable()
                .placeholder {
                    Rectangle()
                        .foregroundStyle(.black.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 12))
                }
                .frame(width: 150, height: 150)
                .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
        }
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
