//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: View {
    @EnvironmentObject private var mainRounter: MainRouter
    
    let message: Message
    
    @State private var presentAlert = false
    
    var body: some View {
        HStack {
            if message.sender == .me {
                emptySpacer
            }
            
            switch message.contentType {
            case .plainText:
                PlainTextMessageView(message: message)
            case .image:
                ImageMessageView(message: message)
            }
            
            if message.sender == .other {
                emptySpacer
            }
        }
        .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
        .onLongPressGesture {
            if message.sender == .me {
                presentAlert = true
            }
        }
        .confirmationDialog("", isPresented: $presentAlert) {
            Button("메시지 삭제", role: .destructive) {
                if message.contentType.isImage {
                    PersistenceController.shared.deleteImageMessage(message)
                } else {
                    PersistenceController.shared.delete(message)
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
                .foregroundColor(message.sender == .me ? theme.myMessageFontColor : theme.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .me ? theme.myMessageBubbleColor : theme.otherMessageBubbleColor)
                .cornerRadius(12)
        }
    }
    
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
                .task(id: retryCount) {
                    do {
                        let ckAsset = try await message.getAsset()
                        if let url = ckAsset.fileURL {
                            imageState = .success(url)
                        } else {
                            imageState = .failure()
                        }
                    } catch {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if retryCount < 5 {
                                retryCount += 1
                            } else {
                                imageState = .failure(error)
                            }
                        }
                    }
                }
        }
        
        private func imageLoadedView(url: URL) -> some View {
            WebImage(url: url)
                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: 200)
                .frame(width: 200, height: 200)
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
                .frame(width: 200, height: 200)
                .foregroundColor(.black.opacity(0.5))
                .background(
                    Group {
                        if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        }
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
        let msg: Message
        
        init() {
            msg = Message(context: PersistenceController.shared.context)
            msg.contentValue = "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World"
            msg.sender = .me
        }
        
        var body: some View {
            MessageView(message: msg)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
