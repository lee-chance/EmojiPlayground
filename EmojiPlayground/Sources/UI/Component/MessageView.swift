//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: View {
    @Environment(\.theme) var theme
    @EnvironmentObject var mainRounter: MainRouter
    
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
            case .localImage, .storageImage:
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
            if message.contentType.isLocalImage {
                if let url = URL(string: message.contentValue) {
                    Button("보관함에 저장") {
                        saveToStorage(url: url)
                    }
                }
            }
            
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
    
    private func saveToStorage(url: URL) {
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
                
                PersistenceController.shared.update(message: message, type: .storageImage, value: url.absoluteString)
                
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

extension MessageView {
    struct PlainTextMessageView: View {
        @Environment(\.theme) var theme
        
        let message: Message
        
        var body: some View {
            Text(message.contentValue)
                .foregroundColor(theme.primaryFontColor)
                .padding(12)
                .background(message.sender == .me ? theme.primaryColor : .white)
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
                .scaledToFit()
                .frame(maxWidth: 200)
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
                .background(.thickMaterial)
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
