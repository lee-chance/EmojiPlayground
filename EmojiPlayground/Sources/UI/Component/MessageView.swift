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
                .foregroundColor(message.sender == .to ? theme.myMessageFontColor : theme.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .to ? theme.myMessageBubbleColor : theme.otherMessageBubbleColor)
                .cornerRadius(12)
        }
    }
    
    // FIXME: CloudKit -> 파이어베이스로 바꾸면서 이미지 불러오기 성공확률이 높아졌으므로 좀더 심플하게 수정하자!
    struct ImageMessageView: View {
        let message: Message
        
        @State private var imageState: ImageState = .loading
        @State private var retryCount: Int = 0
        
        var body: some View {
            switch imageState {
            case .loading:
                loadingView()
            case .success(let url):
                imageLoadedView(url: url)
            case .failure:
                failureView()
            }
        }
        
        private func loadingView() -> some View {
            commonMaterialView
                .overlay(
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                )
                .task {
                    if let url = message.imageURL {
                        imageState = .success(url)
                    } else {
                        imageState = .failure()
                    }
                }
        }
        
        private func imageLoadedView(url: URL) -> some View {
            WebImage(url: url)
                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: 200)
                .frame(width: 150, height: 150)
                .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
        }
        
        private func failureView() -> some View {
            commonMaterialView
                .overlay(
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        
                        Text("Tap to retry")
                    }
                        .foregroundColor(.white)
                )
                .onTapGesture {
                    imageState = .loading
                }
        }
        
        private var commonMaterialView: some View {
            Rectangle()
                .frame(width: 150, height: 150)
                .foregroundColor(.black.opacity(0.5))
                .background(
                    Group {
//                        if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
//                            Image(uiImage: uiImage)
//                                .resizable()
//                                .scaledToFill()
//                        }
                    }
                )
                .cornerRadius(12)
        }
        
        enum ImageState {
            case loading
            case success(URL)
            case failure(Error? = nil)
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
