//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView<Store: ChatStoreProtocol>: View {
    @Environment(\.theme) var theme
    
    @StateObject var chatting: Store
    let message: Message
    
    @State private var removeAlert = false
    
    var body: some View {
        HStack {
            if message.sender == .me {
                emptySpacer
            }
            
            switch message.content {
            case .string(let content):
                Text(content)
                    .foregroundColor(theme.primaryFontColor)
                    .padding(12)
                    .background(message.sender == .me ? theme.primaryColor : .white)
                    .cornerRadius(12)
                
            case .url(let content):
                ZStack {
                    let data = try! Data(contentsOf: content)
                    switch message.type {
                    case .image:
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 200, alignment: message.sender.messageAlignment)
                                .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
                        }
                    case .emoji:
                        AnimatedImage(data: data)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200, alignment: message.sender.messageAlignment)
                            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
                    default: EmptyView()
                    }
                }
                
            default: emptySpacer
            }
            
            if message.sender == .other {
                emptySpacer
            }
        }
        .onLongPressGesture {
            removeAlert = true
        }
        .alert(isPresented: $removeAlert) {
            Alert(
                title: Text("삭제"),
                message: Text("메시지 삭제??"),
                primaryButton: .destructive(Text("삭제"), action: {
                    withAnimation {
                        chatting.messages.removeAll(where: { $0.id == message.id })
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
    
    private var emptySpacer: some View {
        Text(" ")
            .frame(width: Screen.width * 0.15)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let msg = Message(content: .string(content: "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World"), sender: .me, type: .text)
        MessageView(chatting: ChatStore(), message: msg)
    }
}
