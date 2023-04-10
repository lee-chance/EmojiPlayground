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
    @EnvironmentObject var mainRounter: MainRouter
    
    @StateObject var chatting: Store
    let message: Message
    
    @State private var presentAlert = false
    
    var body: some View {
        HStack {
            if message.sender == .me {
                emptySpacer
            }
            
            switch message.content {
            case .plainText(let content):
                Text(content)
                    .foregroundColor(theme.primaryFontColor)
                    .padding(12)
                    .background(message.sender == .me ? theme.primaryColor : .white)
                    .cornerRadius(12)
                
            case .localImage(let url), .storageImage(let url):
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
            }
            
            if message.sender == .other {
                emptySpacer
            }
        }
        .onLongPressGesture {
            if message.sender == .me {
                presentAlert = true
            }
        }
        .confirmationDialog("", isPresented: $presentAlert) {
            if let url = message.content.getLocalImageURL() {
                Button("보관함에 저장") {
                    Task {
                        do {
                            mainRounter.show {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .foregroundColor(.white)
                            }
                            
                            let url = try await FirebaseStorageManager.upload(from: url, to: "image")
                            
                            try await FirestoreManager.reference(path: .images)
                                .document()
                                .setData(["image_url" : url.absoluteString])
                            
                            mainRounter.show {
                                Image(systemName: "checkmark.circle")
                                    .resizable()
                                    .foregroundColor(.green)
                                    .frame(width: 100, height: 100)
                                    .onTapGesture {
                                        mainRounter.hide()
                                    }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
            Button("메시지 삭제", role: .destructive) {
                withAnimation {
                    chatting.messages.removeAll(where: { $0.id == message.id })
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

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let msg = Message(content: .plainText(content: "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World"), sender: .me)
        MessageView(chatting: ChatStore(), message: msg)
    }
}
